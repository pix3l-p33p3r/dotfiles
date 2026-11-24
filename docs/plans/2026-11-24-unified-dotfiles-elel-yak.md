# Plan: Unified Nix Base + 1337 Deviant (`elel-yak`) in `pix3l-p33p3r/dotfiles`

## First-Principles Summary

- **Pure outcome:** One repository (`pix3l-p33p3r/dotfiles`), one root `flake.nix`, two Home Manager profiles: `pixel-peeper@alucard` (NixOS base) and `elel-yak` (1337 Ubuntu + `nix-user-chroot` deviant) sharing portable `configs/` modules directly.
- **Discarded conventions:** Sparse-checkout (entire repo is 2.0 MB), nested duplicate `homes/elel-yak/flake.nix` + `flake.lock`, manually copied `tmux`/`yazi`/`git`/`bat`/`btop` configs.
- **Hard constraints kept:** Host-visible real files outside `nix-user-chroot` (`~/.zshenv`, `~/.config/kitty/kitty.conf`, `~/.local/share/applications/*.desktop`, `/goinfre/elel-yak/theme-assets`), 4.7G `$HOME` quota (XDG on `/goinfre`), kernel 5.15 (`pkgs2405.mesa.opencl`), no GPG private key on cluster (`commit.gpgsign = false`), no Hyprland/Stylix/Lanzaboote/SOPS host secrets.

## Implementation Steps

1. **Full checkout:** `git sparse-checkout disable` in `~/dotfiles-terminal` so `machines/`, `configs/{development,productivity,security,browsers,desktop,devops,media}`, and `assets/` are present.
2. **Root `flake.nix`:** Add lazy inputs `nixpkgs-2405` and `nix-index-database`; export `homeConfigurations."elel-yak"` and `packages.${system}.hm`; remove redundant `homes/elel-yak/flake.{nix,lock}`.
3. **Shared imports in `homes/elel-yak/home.nix`:**
   - Import `../../configs/terminal/tmux.nix`, `../../configs/terminal/yazi.nix`, `../../configs/development/git.nix`.
   - Override `programs.git.settings.commit.gpgsign = lib.mkForce false;`.
   - Enable `catppuccin` (mocha/lavender) for portable CLI/TUI apps (`bat`, `btop`, `eza`, `fzf`, `tmux`, `atuin`, `lazygit`) while keeping `catppuccin.kitty.enable = false`.
   - Enable `programs.atuin.enable = true;`.
4. **Cluster shell & kitty parity:**
   - Add `shell zsh` to `homes/elel-yak/modules/kitty.conf`.
   - Guard `configs/terminal/zsh/config/conf.d/107-goinfre.zsh` with `[[ -d "/goinfre/$USER" ]] || return 0` so shared zsh config is 100% safe on `alucard`.
   - Remove stray `.zshrc` backup files.
   - Update `homes/elel-yak/README.md` for root flake usage.
5. **Verification:**
   - `nix eval` both `homeConfigurations."pixel-peeper@alucard"` and `homeConfigurations."elel-yak"`.
   - `home-manager switch --flake .#elel-yak -b hm-bak`.
   - Verify real files (`~/.config/kitty/kitty.conf`, `~/.zshenv`), interactive zsh (`fastfetch` + `agkozak` `❯`), `git`, `tmux`, `yazi`.
6. **Ship:** Clean review, commit on `feat/1337-home-manager`, push to `origin`, open PR against `main`.
