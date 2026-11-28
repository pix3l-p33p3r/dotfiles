# elel-yak @ 1337 (goinfre)

Standalone **Home Manager** deviant profile in the unified `pix3l-p33p3r/dotfiles` flake for 1337 Ubuntu + `nix-user-chroot`.

## Daily use

```bash
nix-up               # apply the repo to this machine (any machine, any state)
nix-rollback         # go back one Home Manager generation
goinfre-heal --check # ready or not, why, and free space
```

Edit files in `~/dotfiles-terminal`, then `nix-up`. Files under `~/.config/zsh`,
`~/.local/bin` and `~/.local/share/applications` are generated: hand edits are
overwritten on the next switch.

## How it stays pure

| Property | How |
|---|---|
| Reproducible | `flake.lock` pins every input. Zsh plugins, grok and the Cursor CLI are pinned by rev + hash. The two bootstrap downloads (nix-user-chroot, Nix installer) are sha256-checked. |
| Declarative | Apps, launchers, dock entries, icons, dock order, theme and `nix.conf` are all in `homes/elel-yak`. `nix-setup` only installs Nix and runs one switch. |
| Purely functional | Activation copies store paths only (`home.hostFiles`, `modules/host-files.nix`). Nothing reads the working tree at activation time. |
| Atomic rollbacks | `nix-rollback` = `home-manager switch --rollback`. Host files follow the generation; files a generation drops are deleted. |
| Isolation | The store lives in nix-user-chroot on goinfre; project toolchains come from devenv/direnv. |

Deliberate exceptions:

- Host-visible files are copies, not symlinks: GNOME, host systemd and host zsh run outside the chroot where `/nix` does not exist. They are generated from the active generation, so they still roll back with it.
- `nix-setup` is a script because it runs before Nix exists.
- `antigravity-ide` patches its FHS wrapper at launch (parcel watcher stub).
- State is not managed: shell history, app data and caches live on goinfre.

## New machine or wiped goinfre

Nothing to type. `$HOME` (with `~/dotfiles-terminal`) follows you between cluster
machines; `/goinfre` does not. At every graphical login `goinfre-heal.service`
checks this machine and, if Nix is missing or stale, runs `nix-setup` in the
background (about 10 min, desktop notification at start and end). Until then kitty
opens `gnome-terminal` and other launchers tell you setup is in progress.
`tail -f /goinfre/$USER/setup.log` shows progress.

`nix-up` and `nix-rollback` are aliases at the top of `.zshrc`, so they exist
before plugins or Nix do.

Both `nix-up` and the login check refuse to start when `/goinfre` lacks space:
25 GiB on a fresh machine, otherwise Nix's own `--dry-run` download size + 3 GiB.
Free space with `clean` (Nix garbage collection), then run `nix-up` again.

## What it shares from the NixOS base (`configs/`)

- `configs/terminal/tmux.nix`, `configs/terminal/yazi.nix`, `configs/terminal/zsh/config` + `plugins.nix`, `configs/terminal/nvim/conf`
- `configs/development/git.nix` (with `commit.gpgsign = false` override on cluster)
- Catppuccin Mocha Lavender via `catppuccin.homeModules.catppuccin` (`bat`, `btop`, `eza`, `fzf`, `tmux`, `atuin`, `lazygit`)
- `programs.atuin`

## Cluster-specific deviations

- XDG cache/data/state on `/goinfre/elel-yak`; Lean `ELAN_HOME` on hynix
- GTK/icon/font assets copied to `/goinfre/elel-yak/theme-assets`
- `pkgs2405.mesa.opencl` for kernel 5.15 rusticl dual-GPU OpenCL
- `comma` (`, pkg`) via `nix-index-database`
- Antigravity + Codex Desktop wrappers (`--no-sandbox`)

## Relation to `pixel-peeper@alucard`

Full NixOS + Hyprland lives in `machines/alucard` + `homes/pixel-peeper`. Both profiles live in the same root `flake.nix`.
