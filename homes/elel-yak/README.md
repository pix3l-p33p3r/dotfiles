# elel-yak @ 1337 (goinfre)

Standalone **Home Manager** for the school Ubuntu + `nix-user-chroot` setup.

## Switch

```bash
# inside nix namespace (interactive zsh already nix-enter's)
cd ~/dotfiles-terminal/homes/elel-yak
nix run .#hm -- switch --flake .#elel-yak
# or after first install:
home-manager switch --flake .#elel-yak
```

## What it manages

- CLI / TUI stack (lazygit, lazydocker, yazi, btop, …)
- Zsh config from `configs/terminal/zsh/config` + cluster `.zshenv`
- Google Chrome desktop entry + GNOME dock pin
- Antigravity CLI / Hub / IDE (Hy4ri flake, `--no-sandbox`)

## Not managed here

- Cursor / Grok Bot AppImages → `~/.local/bin/nix-setup` + goinfre
- Nested i3 / tiling → separate step

## Relation to `pixel-peeper@alucard`

Full NixOS + Hyprland lives in `homes/pixel-peeper`. This flake is the **cluster subset** only.
