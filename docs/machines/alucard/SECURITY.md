# Security Configuration

System-level security for alucard: AppArmor, nftables firewall, ClamAV, and OpenSSH hardening.

## AppArmor (`security.nix`)

AppArmor is enabled as an LSM (Linux Security Module). It enforces mandatory access control policies on processes where profiles exist, and leaves everything else running normally.

```nix
security.apparmor = {
  enable                   = true;
  killUnconfinedConfinables = false;  # don't kill processes without profiles
  packages                 = [ pkgs.apparmor-profiles ];
};
```

`killUnconfinedConfinables = false` is the right choice for a workstation — it means AppArmor enforces where it has profiles (system utilities, daemons) without breaking apps that don't have profiles yet.

**Check AppArmor status:**
```bash
sudo aa-status           # list enforced/complain profiles
sudo aa-complain /path   # put a profile in complain mode
sudo aa-enforce /path    # put a profile in enforce mode
journalctl -k | grep apparmor  # view denials
```

---

## Firewall (`firewall.nix`)

nftables-based, default-deny incoming, stealth drop mode.

```nix
networking.nftables.enable = true;

networking.firewall = {
  enable         = true;
  rejectPackets  = false;   # drop (stealth) rather than ICMP reject
  allowedTCPPorts = [ 22 ]; # SSH; IPsec ports live in vpn.nix
};
```

Docker keeps working via `iptables-nft` compatibility wrappers that NixOS provides automatically.

**Check firewall status:**
```bash
sudo nft list ruleset         # show all nftables rules
sudo nft list table inet filter  # show the main filter table
systemctl status nftables
```

### Network hardening sysctls

| sysctl | Value | Effect |
|--------|-------|--------|
| `net.ipv4.conf.all.accept_redirects` | 0 | Ignore ICMP redirects (routing table poisoning) |
| `net.ipv4.conf.all.send_redirects` | 0 | Don't act as a router |
| `net.ipv4.conf.all.rp_filter` | 2 | Loose reverse-path filter (spoofing protection, Docker-safe) |
| `net.ipv4.tcp_syncookies` | 1 | SYN flood protection |
| `net.ipv4.icmp_echo_ignore_broadcasts` | 1 | Ignore broadcast pings |
| `net.ipv6.conf.all.accept_ra` | 0 | Don't accept IPv6 router advertisements |

---

## ClamAV (`clamav.nix`)

Resident daemon with automatic signature updates and a daily scheduled scan.

| Component | Role |
|-----------|------|
| `clamd` | Resident scanning daemon |
| `freshclam` | Pulls updated virus signatures (twice daily) |
| `clamav-scan` timer | Scans `/home` + `/etc` daily at 03:00 |

**Excluded from scanning:** `/nix/store`, `/proc`, `/sys`, `/run`, `/dev`

**On-access scanning is disabled** — the fanotify kernel hook adds latency to every file open and drains battery. The daily timer is the right trade-off for a laptop.

**Useful commands:**
```bash
# Service status
systemctl status clamav-daemon freshclam

# Manual scan
clamdscan --fdpass --recursive /path/to/scan

# Check when next scan runs
systemctl list-timers clamav-scan

# View last scan output
journalctl -u clamav-scan

# Force signature update now
sudo freshclam

# Check signature database age
sigtool --info /var/lib/clamav/main.cvd
```

---

## OpenSSH hardening (`security.nix`)

SSH is hardened beyond NixOS defaults:

- Password and keyboard-interactive auth disabled (public key only)
- Root login prohibited
- X11 and TCP forwarding disabled
- Max 3 auth attempts, 2 sessions, 30s grace period
- Ciphers restricted to ChaCha20-Poly1305 and AES-GCM
- MACs restricted to HMAC-SHA2 ETM variants
- KEX restricted to X25519 and NIST P-curves

---

## See Also

- [TPM2-LUKS.md](TPM2-LUKS.md) — TPM2 LUKS auto-unlock (boot-time encryption)
- [configs/security/KEEPASSXC.md](../../docs/configs/security/KEEPASSXC.md) — SSH agent and secrets management
- [secrets/README.md](../../secrets/README.md) — SOPS/Age encrypted secrets
