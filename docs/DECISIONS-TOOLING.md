# Tooling Decisions

Decisions about specific tools and workflows in this configuration.

## Tmux vs Zellij

**Decision:** Stick with tmux

SSH-first workflow; tmux is ubiquitous on remote systems (no extra install or config). Scriptability and stability over novelty; mature plugin ecosystem. Tight integration with existing aliases, Hyprland keybinds, and CLI tools.

**Why tmux?**
- Battle-tested, low overhead, available everywhere (servers, containers, CI)
- Rich scripting (shell-first), tmuxp/tmuxinator session definitions
- Works seamlessly inside any terminal (Kitty) and over SSH
- Easier interop with tools like Taskwarrior/Timewarrior for status lines and hooks

**Why not Zellij?**
- Not guaranteed to exist on servers; increases friction in remote work
- Different keybindings/workflows; retraining cost with little tangible gain
- Plugin/story still evolving; fewer battle-tested integrations

**ROI:** tmux wins on portability, stability, and automation for my workflow.

## Taskwarrior + Timewarrior + tmux

**Decision:** Switch to Taskwarrior 3 + Timewarrior with official on-modify hook

Keeping the same frictionless workflow, now on Taskwarrior 3.

**Why?**
- Time tracking is paramount: the `on-modify` hook continues to auto-start/stop Timewarrior
- Taskwarrior 3 improvements while preserving CLI-first flow and TUI compatibility
- Official Timewarrior hook is used directly from the package (no custom script)

**What's configured:**
- Packages: `taskwarrior3`, `timewarrior`, `taskwarrior-tui`, `timew-sync-server` (in `configs/productivity/task-timewarrior.nix`)
- Hook: `~/.task/hooks/on-modify.timewarrior` sourced from `${pkgs.timewarrior}/share/doc/timew/ext/on-modify.timewarrior`
- Aliases: quick `task` and `timew` helpers (in `configs/terminal/zsh/config/conf.d/102-aliases.zsh`)
- tmux: `configs/terminal/tmux.nix` with Catppuccin theme + plugins + keybinds

**Technical notes:**
- `.taskrc` remains in `$HOME` for compatibility with tools (including Taskwarrior-TUI)
- The upstream hook handles the integration; no `jq` dependency needed

**Future:** tmux status integration, session automation (tmuxp), templated reports, optional sync server, encrypted backups.

## Filesystem: ext4 vs Btrfs

**Decision:** Prefer Btrfs with subvolumes + zstd compression

For this laptop (NVMe 256 GB), development-heavy workflow, frequent Nix rebuilds, and need for fast rollbacks and lower write amplification, Btrfs is the best fit.

**Why?**
- Snapshots & rollbacks: enables instant pre/post `nixos-rebuild` rollbacks
- Compression (zstd): reduces writes and space, speeds many desktop/dev workloads
- Subvolumes: isolate `/`, `/home`, `/nix`, `/var/log`, `/.snapshots` for clarity and maintenance
- Health: NVMe is healthy (0 media errors, ~5% wear), so Btrfs' features outweigh ext4's simplicity

**Recommended layout:**
- Subvolumes: `@` (root), `@home`, `@nix`, `@var_log`, `@snapshots` (optionally `@cache`)
- Mount options (per mount): `compress-force=zstd:3,ssd,noatime,space_cache=v2,autodefrag,discard=async`
- TRIM: keep weekly TRIM via `services.fstrim.enable = true;` (complements or replaces `discard=async`)

**If staying on ext4:**
- Keep zram swap (already configured) and low swappiness
- Use `noatime,lazytime,commit=60` and enable `services.fstrim.enable = true;`

**Migration path:**
- Non-destructive: ext4 → Btrfs in-place using `btrfs-convert` (keeps an ext4 rollback image until you drop it)
- Fresh install: create Btrfs, define subvolumes, restore `/home`, then `nixos-install` using the flake

See [MIGRATE-EXT4-TO-BTRFS.md](MIGRATE-EXT4-TO-BTRFS.md) for detailed, step-by-step instructions, safety notes, and rollback procedure.

---

**See Also:**
- [DECISIONS.md](DECISIONS.md) - Core architectural decisions
- [SHORTCUTS.md](SHORTCUTS.md) - Keybinds and aliases

