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

## ClamAV: deferred daemon start

**Decision:** Remove `clamav-daemon` from `multi-user.target`, start it ~45s after boot via a timer, and drop nixpkgs’ `wants`/`after` on `clamav-freshclam` for clamd.

**Why:** Upstream ties clamd after freshclam, so freshclam ran on every boot before clamd, adding several seconds to the critical path to `graphical.target`. The socket unit still allows activation on demand; the timer ensures the daemon is up shortly after login without blocking boot.

**Scheduled scan:** `clamav-scan.service` uses `Requires=`/`After=` `clamav-daemon.socket`, waits for `/run/clamav/clamd.ctl`, then runs `clamdscan`. Timer fires on the **1st and 15th** at 03:00 (not daily — full scans take hours). Reports go to `/var/log/clamav/`. Browser/IDE extension paths are excluded after Fangfrisch `.UNOFFICIAL` false positives on legitimate `.xpi`/VSIX files.

---

## Waydroid removed

**Decision:** Do not run Waydroid. Android is a phone; the LXC stack (binderfs, `waydroid0`, images) is unused boot and disk cost.

---

## WinApps for Perplexity Comet (Windows VM)

**Decision:** Run Comet via WinApps + libvirt (`RDPWindows` VM).

**Why:** Perplexity ships Comet desktop for Windows/macOS only — no native Linux build. WinApps remotes individual app windows over FreeRDP (`wlfreerdp` on Hyprland).

**Setup:** [docs/WINAPPS.md](WINAPPS.md) — create Windows 11 **Pro** VM in virt-manager, run WinApps OEM `install.bat`, install Comet, then `winapps-setup --user`. Menu: `Super+Shift+W` / `comet` alias.

---

## Codex Desktop (ChatGPT GUI) on NixOS

**Decision:** Install via `github:ilysenko/codex-desktop-linux` Home Manager module (`programs.codexDesktopLinux`), not AppImage or mutable `/opt` installs.

**Why:** OpenAI’s ChatGPT/Codex desktop is packaged as a Linux `.deb`; the flake wraps that payload for the Nix store (ELF audit + library path), exposes `codex-desktop`, and ships a cachix. Matches the Antigravity/Zen pattern: flake input + HM enable + editor config under `configs/editors/`.

**Update:** `nix flake update codex-desktop-linux` then `home-manager switch --flake .#pixel-peeper@alucard`. Nix store builds do not use the in-app updater.

---

## Hardware profile: T14s Intel Gen 2 (upstream + local)

**Decision:** Treat alucard as ThinkPad T14s Gen 2i (`20WNS1R800`). Locally import generic `lenovo-thinkpad-t14s` + `common/cpu/intel/tiger-lake` + `common-pc-ssd`, and keep chassis quirks in `machines/alucard/thinkpad.nix`. Upstream the same layout as `lenovo-thinkpad-t14s-intel-gen2`.

**Why:** nixos-hardware had AMD T14s gens and a generic T14s, but no Intel Gen 2. `tiger-lake` sets `hardware.intelgpu.vaapiDriver = "intel-media-driver"` (iHD only) and `i915.enable_guc=3`. We still set `i915.enable_psr=0` for the SYNA800E I2C/touchpad lockup.

**Local extras** (not for upstream): Thunderbolt `boltd`, fprintd forced off. **Upstream extras:** BIOS Sleep State note, thermald/throttled `mkDefault false`.

**Contribution:** fork `pix3l-p33p3r/nixos-hardware`, branch `add-thinkpad-t14s-intel-gen2` at `~/nixos-hardware`. Sign/push from a real terminal (GPG pinentry), then `gh pr create --repo NixOS/nixos-hardware`.

**nixos-facter:** Optional scan only. Do **not** commit the JSON or enable `hardware.facter` — the report is a 4k-line dump and the modules would add initrd/IPU6/fprintd we do not want on the boot path. When you need a snapshot: `sudo nix run .#facter -- -o /tmp/facter.json`.

**Not added:** `auto-cpufreq` (fights TLP), `throttled` (older ThinkPads / missing DPTF — Tiger Lake + TLP/thinkfan already cover this), `common-gpu-intel`.

**nvtop:** System package (`nvtopPackages.intel`) plus `security.wrappers` with `cap_perfmon` for `nvtop` and `intel_gpu_top`. Do not drop `kernel.perf_event_paranoid=3` just to make GPU monitors work.

---

## Local overlays vs nixpkgs

**Decision:** Drop version-bump overlays once the pinned `nixos-unstable` already has a newer official package. Keep fetch-and-wrap AppImages when nixpkgs is older, missing, or would compile from source.

**Why:** `overlays/ani-cli.nix` (4.12), `overlays/google-chrome.nix` (148.0.7778.178), and `overlays/stremio-linux-shell.nix` (cargo vendor glob) were ahead of an older pin. The current pin already has google-chrome 149.0.7827.114 and the stremio postPatch from nixpkgs#503035 — those overlays were downgrading or no-ops. ani-cli 4.14 on the pin is dead; `configs/media/pkgs.nix` callPackages the official nixos-unstable `package.nix` (5.1) until the pin moves.

**Still local (not nixpkgs):**
- Cursor: official AppImage wrap (`configs/editors/cursor.nix`). Pin's `code-cursor` is 3.7.19; nixpkgs `buildVscode` is uncached unfree and not a Chrome-style wrap.
- Grok Bot: official AppImage wrap. Not in nixpkgs master yet.
- LibreWolf: official AppImage wrap. `pkgs.librewolf` is a Firefox source rebuild.

---

## CLI: store binaries, not repo-path bash

**Decision:** Do not invoke `~/dotfiles/scripts/*.sh` from zsh, Wayle, or docs. Daily tools are `writeShellApplication` / `programs.nh` in the Home Manager or NixOS closure. One-shot installers (sed-the-config Secure Boot, live-ISO Btrfs convert) were deleted; the docs remain.

**Why:** Repo-path scripts break under sudo (`$HOME` → `/root`), drift from the generation, and are not atomic. `nh os switch` / `nh home switch` replace `nrs`/`hms` wrappers.

**sudo:** Never add `pkgs.sudo` to `writeShellApplication.runtimeInputs`. That store binary has no setuid bit; callers must use `/run/wrappers/bin/sudo`.

---

**See Also:**
- [DECISIONS-TOOLING.md](DECISIONS-TOOLING.md) - Tool choices (tmux, Taskwarrior, filesystem)
- [HOME-MANAGER.md](HOME-MANAGER.md) - Standalone Home Manager guide
- [secrets/README.md](../secrets/README.md) - SOPS secrets management
