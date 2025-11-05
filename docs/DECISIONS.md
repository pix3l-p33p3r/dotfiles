# Tooling Decisions

Key decisions about tools and technologies used (or not used) in this dotfiles configuration.

---

## Git vs Jujutsu (jj)

### Decision: Stick with Git

I evaluated `jj` (Jujutsu), a modern Git-compatible VCS, but decided to stick with Git.

### Why?

**My Setup:**
- Small dotfiles repository - Git handles it perfectly
- Solo development - no complex merge conflicts
- Existing workflow with `lazygit`, Neovim plugins, GitHub CLI
- Nix/Flakes ecosystem expects Git

**Pros of jj:**
- Better conflict handling
- Automatic snapshots
- Faster on large repos (10k+ files)
- Git compatible

**Cons for my use case:**
- Learning curve with limited benefit
- Ecosystem incompatibility (`lazygit`, Neovim plugins)  
- Maintenance overhead (need to know both tools)
- NixOS ecosystem assumes Git

**ROI:** Low to negative for dotfiles; might reconsider for large monorepos.

---

## Home Manager: Standalone vs Integrated

### Decision: Standalone Home Manager

I chose to run Home Manager independently from NixOS system configuration.

### Why?

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

---

## Nix Build Optimizations

### Decision: Enable Parallel Builds & Auto-Optimization

Configured Nix to maximize build performance and minimize disk usage.

### Why?

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

**For practical guides, see:**
- Home Manager usage: `docs/HOME-MANAGER.md`
- Secrets management: `secrets/README.md`
- Font configuration: `docs/FONTS.md`


---

## Tmux vs Zellij

### Decision: Stick with tmux

I evaluated Zellij as a modern terminal workspace manager but decided to keep tmux as the daily driver.

### Why?

**My Setup & Priorities:**
- SSH-first workflow; tmux is ubiquitous on remote systems (no extra install or config)
- Scriptability and stability over novelty; mature plugin ecosystem
- Tight integration with existing aliases, Hyprland keybinds, and CLI tools

**Pros of tmux:**
- Battle-tested, low overhead, available everywhere (servers, containers, CI)
- Rich scripting (shell-first), tmuxp/tmuxinator session definitions
- Works seamlessly inside any terminal (Kitty) and over SSH
- Easier interop with tools like Taskwarrior/Timewarrior for status lines and hooks

**Pros of Zellij (acknowledged):**
- Safer defaults, smart layouts, built-in UI features
- Plugin system (WASM) with modern ergonomics

**Cons (for my use case):**
- Not guaranteed to exist on servers; increases friction in remote work
- Different keybindings/workflows; retraining cost with little tangible gain
- Plugin/story still evolving; fewer battle-tested integrations

**ROI:** tmux wins on portability, stability, and automation for my workflow.

---

## Taskwarrior + Timewarrior + tmux (Legendary Combo)

### Decision: Switch to Taskwarrior 3 + Timewarrior with official on-modify hook

Keeping the same frictionless workflow, now on Taskwarrior 3.

### Why?
- Time tracking is paramount: the `on-modify` hook continues to auto-start/stop Timewarrior
- Taskwarrior 3 improvements while preserving CLI-first flow and TUI compatibility
- Official Timewarrior hook is used directly from the package (no custom script)

### What's configured here
- Packages: `taskwarrior3`, `timewarrior`, `taskwarrior-tui`, `timew-sync-server` (in `configs/productivity/task-timewarrior.nix`)
- Hook: `~/.task/hooks/on-modify.timewarrior` sourced from `${pkgs.timewarrior}/share/doc/timew/ext/on-modify.timewarrior`
- Aliases: quick `task` and `timew` helpers (in `configs/terminal/zsh/config/conf.d/102-aliases.zsh`)
- tmux: `configs/terminal/tmux.nix` with Catppuccin theme + plugins + keybinds

### Technical notes
- `.taskrc` remains in `$HOME` for compatibility with tools (including Taskwarrior-TUI)
- The upstream hook handles the integration; no `jq` dependency needed

### tmux integration ideas (current/optional)
- Status line: show current Timewarrior activity (e.g., `timew get dom.active.tag.1`), elapsed time
- Dedicated pane: pin `taskwarrior-tui` in a tmux window for live backlog view
- Session presets: tmuxp file to open editor + task TUI + logs in one command

---

## Room for Improvement

- tmux status integration: add a tiny script for Timewarrior current activity and duration in `status-right`
- Session automation: provide a `tmuxp` profile that auto-launches editor + `taskwarrior-tui` + a notes pane
- Reports: add `haskellPackages.pandoc-crossref`-powered templated weekly reports combining `timew summary` and top tasks
- Sync: optionally run `timew-sync-server` as a user service for background availability
- Backups: periodically export `~/.task` and `~/.timewarrior` to encrypted storage via a `systemd --user` timer
