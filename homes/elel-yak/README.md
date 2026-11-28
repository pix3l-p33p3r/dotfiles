# elel-yak @ 1337 (goinfre)

Standalone **Home Manager** deviant profile in the unified `pix3l-p33p3r/dotfiles` flake for 1337 Ubuntu + `nix-user-chroot`.

## Switch

```bash
# from repo root (inside nix namespace; interactive zsh already nix-enter's)
cd ~/dotfiles-terminal
nix run .#hm -- switch --flake .#elel-yak -b hm-bak
# or after first install:
home-manager switch --flake .#elel-yak -b hm-bak
```

## New machine or wiped goinfre

Nothing to type. `$HOME` follows you between cluster machines; `/goinfre` does not.
At every graphical login `goinfre-heal.service` checks this machine and, if Nix is
missing or stale, runs `nix-setup` in the background (about 10 min, desktop
notification at start and end). Until then kitty opens `gnome-terminal` and other
launchers tell you setup is in progress.

```bash
goinfre-heal --check                 # ready or not, and why
tail -f /goinfre/$USER/setup.log     # watch a rebuild
```

Reset home (nothing in `~/.local/bin`):

```bash
git clone https://github.com/pix3l-p33p3r/dotfiles ~/dotfiles-terminal
~/dotfiles-terminal/homes/elel-yak/bootstrap/install.sh && goinfre-heal
```

## What it shares from the NixOS base (`configs/`)

- `configs/terminal/tmux.nix`, `configs/terminal/yazi.nix`, `configs/terminal/zsh/config`, `configs/terminal/nvim/conf`
- `configs/development/git.nix` (with `commit.gpgsign = false` override on cluster)
- Catppuccin Mocha Lavender via `catppuccin.homeModules.catppuccin` (`bat`, `btop`, `eza`, `fzf`, `tmux`, `atuin`, `lazygit`)
- `programs.atuin`

## Cluster-specific deviations

- XDG cache/data/state on `/goinfre/elel-yak`; Lean `ELAN_HOME` on hynix
- Real host-readable files (not `/nix/store` symlinks) for `~/.zshenv`, `~/.config/kitty/kitty.conf`, desktop entries, and GTK/icon/font assets on `/goinfre/elel-yak/theme-assets`
- `pkgs2405.mesa.opencl` for kernel 5.15 rusticl dual-GPU OpenCL
- `comma` (`, pkg`) via `nix-index-database`
- Antigravity + Codex Desktop wrappers (`--no-sandbox --disable-gpu`)

## Relation to `pixel-peeper@alucard`

Full NixOS + Hyprland lives in `machines/alucard` + `homes/pixel-peeper`. Both profiles live in the same root `flake.nix`.
