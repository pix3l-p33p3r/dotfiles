# KeePassXC

KeePassXC owns all interactive secrets: master password, OTP seeds, SSH/LUKS passphrases, the age private key, and recovery notes.

## SSH Agent Setup

On Linux, KeePassXC does **not** create its own SSH agent socket. It connects to an existing agent (at `$SSH_AUTH_SOCK`) and injects its stored SSH keys into it when the database is unlocked.

`services.ssh-agent.enable = true` in `keepassxc.nix` starts a real `ssh-agent` systemd user service. KeePassXC auto-adds keys to it on database unlock. `AddKeysToAgent yes` in `~/.ssh/config` caches the key on first use, so you only enter the passphrase once per session.

**One-time setup in KeePassXC:**

1. Open KeePassXC → Preferences → SSH Agent
2. Enable SSH Agent integration
3. Leave the SSH_AUTH_SOCK override blank (it reads from the environment automatically)
4. Add your SSH key entry and enable "Add key to agent when database is opened"

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
ssh-agent (systemd user service)
  └── $SSH_AUTH_SOCK (set automatically in systemd user environment)
        ← KeePassXC injects keys on database unlock
        ← AddKeysToAgent yes caches key in agent on first use
        ← all SSH clients use this socket transparently

SOPS + age (automated, no interaction after boot)
  └── Age key: ~/.config/sops/age/keys.txt
        ← decrypts secrets/ during home-manager activation
```

## Related config

- `configs/security/keepassxc.nix` — enables `services.ssh-agent`
- `configs/security/ssh.nix` — `AddKeysToAgent yes`, host entries
- `configs/security/gpg.nix` — GPG agent (separate from SSH agent)
- `secrets/` — SOPS-encrypted secrets decrypted at activation time

## See Also

- [DECISIONS.md](../../DECISIONS.md) — Secrets & OpSec posture decision
- [secrets/README.md](../../../secrets/README.md) — SOPS + age usage
