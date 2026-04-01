# KeePassXC

KeePassXC owns all interactive secrets: master password, OTP seeds, SSH/LUKS passphrases, the age private key, and recovery notes.

## SSH Agent Setup

KeePassXC exposes an SSH agent socket that Home Manager points `SSH_AUTH_SOCK` at.

**One-time setup in KeePassXC:**

1. Open KeePassXC → Preferences → SSH Agent
2. Enable SSH Agent integration
3. Set the socket path to `~/.local/share/keepassxc/ssh-agent`

Once unlocked, `AddKeysToAgent yes` in `~/.ssh/config` caches the key for the session so you are not prompted repeatedly.

## What to store

| Item | Where |
|---|---|
| Master password | Memorized |
| SSH private key passphrase | KeePassXC entry with SSH Agent attachment |
| LUKS passphrase | KeePassXC entry |
| Age private key | KeePassXC entry (copy of `~/.config/sops/age/keys.txt`) |
| OTP seeds | KeePassXC TOTP entries |
| Recovery codes | KeePassXC entry |

## Architecture

```
KeePassXC (unlocked at login)
  └── SSH Agent socket: ~/.local/share/keepassxc/ssh-agent
        ← SSH_AUTH_SOCK (set in keepassxc.nix)
        ← ssh config: Match exec + IdentityAgent
        ← AddKeysToAgent yes (caches key in-session)

SOPS + age (automated, no interaction after boot)
  └── Age key: ~/.config/sops/age/keys.txt
        ← decrypts secrets/ during home-manager activation
```

## Related config

- `configs/security/keepassxc.nix` — sets `SSH_AUTH_SOCK`, ensures socket dir exists
- `configs/security/ssh.nix` — `Match exec` block, `AddKeysToAgent yes`
- `configs/security/gpg.nix` — GPG agent (separate from SSH agent)
- `secrets/` — SOPS-encrypted secrets decrypted at activation time

## See Also

- [DECISIONS.md](../../DECISIONS.md) — Secrets & OpSec posture decision
- [secrets/README.md](../../../secrets/README.md) — SOPS + age usage
