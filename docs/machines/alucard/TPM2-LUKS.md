# TPM2 LUKS Auto-Unlock

LUKS unlocks automatically via TPM2 when the Secure Boot chain is valid. No passphrase prompt on normal boots — falls back to passphrase if the seal breaks.

## How It Works

`systemd-cryptenroll` writes a LUKS token sealed to TPM2 PCRs 0+7:

| PCR | Measures |
|-----|----------|
| 0 | UEFI firmware (BIOS hash) |
| 7 | Secure Boot state (enabled/disabled, PK/KEK/db keys) |

At boot, `systemd-cryptsetup` asks the TPM to unseal the key. If the PCR values match enrollment — Secure Boot is on, keys are the same — the TPM releases the key and LUKS opens silently. If anything changed (Secure Boot disabled, keys rotated, firmware tampered), the TPM refuses and the passphrase prompt appears.

## NixOS Config (`boot.nix`)

```nix
boot.initrd = {
  systemd.enable = true;
  kernelModules = [ "i915" "tpm_tis" ];  # tpm_tis = STM0125 driver on this hardware
  systemd.tpm2.enable = true;            # pulls tpm2-tss into initrd
};

boot.initrd.luks.devices."luks-77036ffc-..." = {
  crypttabExtraOpts = [
    "tpm2-device=auto"
    "tpm2-pcrs=0+7"
    "tries=3"                   # passphrase fallback attempts
    "x-systemd.device-timeout=0"
  ];
};
```

## Initial Enrollment (one-time)

Run after `sudo nixos-rebuild switch`:

```bash
sudo systemd-cryptenroll \
  --tpm2-device=auto \
  --tpm2-pcrs=0+7 \
  /dev/disk/by-uuid/77036ffc-3333-4526-bbe8-c0a6ca58e92e
```

Prompts for the LUKS passphrase once to authorize writing the token into the LUKS header. After reboot — no prompt.

## Re-enrollment

Required after BIOS/UEFI firmware updates (PCR 0 changes) or Secure Boot key rotation (PCR 7 changes):

```bash
# Wipe the old TPM2 token
sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/disk/by-uuid/77036ffc-3333-4526-bbe8-c0a6ca58e92e

# Enroll again
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-uuid/77036ffc-3333-4526-bbe8-c0a6ca58e92e
```

## Verify Enrollment

```bash
# List tokens in the LUKS header
sudo cryptsetup luksDump /dev/disk/by-uuid/77036ffc-3333-4526-bbe8-c0a6ca58e92e | grep -A5 Tokens

# Check TPM2 device
systemd-cryptenroll --tpm2-device=list

# Confirm tpm_tis is loaded in initrd
lsmod | grep tpm
```

## Fallback

If the TPM seal fails for any reason, `tries=3` in crypttabExtraOpts gives three passphrase attempts via the Plymouth password dialog (same two-step theme, same UI — just prompted).

## Security Properties

- TPM2 + Secure Boot (PCR 7) means the key only unseals when the verified boot chain is intact
- An attacker with physical access who disables Secure Boot will not get automatic unlock
- The LUKS passphrase remains enrolled and functional as a fallback — it is not removed by enrollment
- To check enrolled keyslots: `sudo cryptsetup luksDump /dev/disk/by-uuid/...`
