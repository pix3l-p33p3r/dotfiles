{ config, pkgs, lib, ... }:
{
  # NEVER programs.kitty.enable. Kitty starts outside nix-user-chroot.
  # home.file / programs.kitty write /nix/store symlinks, which Kitty cannot
  # read on the host — that drops the theme. Edit modules/kitty.conf instead.
  assertions = [
    {
      assertion = config.programs.kitty.enable == false;
      message = "programs.kitty.enable is forbidden on this cluster. It replaces kitty.conf with a /nix/store symlink and wipes the theme. Edit homes/elel-yak/modules/kitty.conf.";
    }
  ];

  # Keep zsh config in the git tree; symlink into XDG (no HM copy loop).
  home.activation.linkZshConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config"
    ln -sfn "$HOME/dotfiles-terminal/configs/terminal/zsh/config" "$HOME/.config/zsh"
  '';

  # Real files, not /nix/store symlinks. Runs after HM link generation so a
  # store symlink cannot survive a switch.
  home.activation.clusterRealFiles = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    set -eu
    mod="$HOME/dotfiles-terminal/homes/elel-yak/modules"
    install_real() {
      local src="$1" dest="$2"
      if [[ ! -f "$src" ]]; then
        echo "clusterRealFiles: missing $src" >&2
        exit 1
      fi
      rm -f "$dest"
      install -m 644 "$src" "$dest"
      if [[ -L "$dest" || ! -f "$dest" ]]; then
        echo "clusterRealFiles: $dest is still a symlink" >&2
        exit 1
      fi
    }
    mkdir -p "$HOME/.config/kitty" "$HOME/.config/mpv"
    install_real "$mod/zshenv" "$HOME/.zshenv"
    install_real "$mod/kitty.conf" "$HOME/.config/kitty/kitty.conf"
    install_real "$mod/mpv.conf" "$HOME/.config/mpv/mpv.conf"
    grep -q 'include current-theme.conf' "$HOME/.config/kitty/kitty.conf"
    grep -q 'hwdec=auto-copy' "$HOME/.config/mpv/mpv.conf"
    install -m 755 "$mod/nixgl-run.sh" "$HOME/.local/bin/nixgl-run"
    install -m 755 "$mod/kitty-launcher.sh" "$HOME/.local/bin/kitty"
    install -m 755 "$mod/kitten-launcher.sh" "$HOME/.local/bin/kitten"
    install -m 755 "$mod/cursor-launcher.sh" "$HOME/.local/bin/cursor"
    install -m 755 "$mod/cursor-launcher.sh" "$HOME/.local/bin/cursor-ide"
    install -m 755 "$mod/grok-bot-launcher.sh" "$HOME/.local/bin/grok-bot"
    bash "$mod/../bootstrap/install.sh"
  '';

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
