# Core Configuration Decisions

Key architectural decisions for this NixOS dotfiles setup.

## Git vs Jujutsu (jj)

**Decision:** Stick with Git

Small dotfiles repo, solo dev, existing tooling (lazygit, Neovim plugins, GitHub CLI). Nix/Flakes ecosystem expects Git. ROI: Low to negative for dotfiles; might reconsider for large monorepos.

**Why not jj?**
- Learning curve with limited benefit
- Ecosystem incompatibility (lazygit, Neovim plugins)
- Maintenance overhead (need to know both tools)
- NixOS ecosystem assumes Git

## Home Manager: Standalone vs Integrated

**Decision:** Standalone Home Manager

Run Home Manager independently from NixOS system configuration.

**Why?**

**Speed:**
- User environment rebuilds in 30 seconds (vs 5+ minutes integrated)
- No sudo needed for most daily changes
- Fast iteration encourages experimentation

**Separation:**
- Clear boundary between system and user config
- Independent rollbacks (break user config without affecting system)
- Safer experimentation

**Workflow:**
```bash
sudo nixos-rebuild switch --flake .#alucard     # System
home-manager switch --flake .#pixel-peeper@alucard  # User
# Or: upgrade (does both + cleanup)
```

**Trade-offs:**
- Two commands instead of one (mitigated by aliases)
- Need to coordinate flake updates
- Less common pattern (most tutorials use integrated)

**ROI:** High for actively developed configs; would use integrated for set-and-forget servers.

## Secrets & OpSec Posture

**Decision:** Split automation vs. interactive secrets

**Automation (SOPS + age):**
- Auto-rehydrating secrets (git signing key, API tokens, desktop services) in `secrets/` decrypted via `sops-nix` during activation. Single age key at `~/.config/sops/age/keys.txt` shared by Home Manager and host for one-time rotation. [[Mic92/sops-nix](https://github.com/Mic92/sops-nix)]
- Private age key never enters git; stored offline in KeePassXC. Rotation: export temp ASCII armor, update SOPS YAML, re-key, delete exports.
- `home.activation.ensureAgeKey` fails early if key missing.

**Interactive (KeePassXC):**
- Source of truth for manual approval: master password, OTP seeds, SSH/LUKS passphrases, age key, recovery notes. Autostarts with SSH agent at `~/.local/share/keepassxc/ssh-agent`.
- SSH clients use `IdentityAgent`/`SSH_AUTH_SOCK` for "approve each use" flow.

**Transport security:**
- OpenSSH daemon: public-key auth only, hardened Ciphers/Kex/MACs per NixOS guide. [[NixOS SSH guide](https://wiki.nixos.org/wiki/SSH)]

**Rotation:** Unlock KeePassXC → duplicate entries → export keys → update SOPS → rebuild → delete exports → update KeePassXC.

This split keeps automation unattended while manual secrets require KeePassXC approval. [[ryantm/agenix](https://github.com/ryantm/agenix)]

## Nix Build Optimizations

**Decision:** Enable Parallel Builds & Auto-Optimization

Configured Nix to maximize build performance and minimize disk usage.

**Why?**

**Performance:**
- `max-jobs = "auto"` - Uses all available CPU cores
- `cores = 0` - Each job can use all cores when beneficial
- Faster rebuilds and package builds

**Disk Management:**
- `auto-optimise-store = true` - Automatically deduplicates identical files via hardlinks
- `nix.gc.automatic = true` - Weekly garbage collection of old generations (>7 days)
- Prevents /nix/store bloat without manual intervention

**Trade-offs:**
- Higher CPU usage during builds (acceptable on modern hardware)
- Slight overhead from automatic optimization (saves GBs of disk space)

**ROI:** High - faster builds + automatic cleanup with minimal configuration.

---

**See Also:**
- [DECISIONS-TOOLING.md](DECISIONS-TOOLING.md) - Tool choices (tmux, Taskwarrior, filesystem)
- [HOME-MANAGER.md](HOME-MANAGER.md) - Standalone Home Manager guide
- [secrets/README.md](../secrets/README.md) - SOPS secrets management
