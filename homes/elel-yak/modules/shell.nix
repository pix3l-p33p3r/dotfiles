{ config, pkgs, lib, ... }:
{
  # Keep zsh config in the git tree; symlink into XDG (no HM copy loop).
  home.activation.linkZshConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config"
    ln -sfn "$HOME/dotfiles-terminal/configs/terminal/zsh/config" "$HOME/.config/zsh"
  '';

  # Cluster entry: goinfre XDG + optional nix-enter
  home.file.".zshenv".text = ''
    # 1337 goinfre + pix3l-p33p3r terminal setup (HM-managed)
    export GOINFRE="/goinfre/$USER"
    export XDG_CACHE_HOME="''${GOINFRE}/cache"
    export XDG_DATA_HOME="''${GOINFRE}/xdg-data"
    export XDG_STATE_HOME="''${GOINFRE}/xdg-state"
    export XDG_CONFIG_HOME="''${HOME}/.config"
    mkdir -p "$XDG_CACHE_HOME/zsh" "$XDG_DATA_HOME" "$XDG_STATE_HOME" 2>/dev/null

    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
    export EDITOR=nvim
    export VISUAL=nvim
    export PATH="$HOME/.local/bin:$GOINFRE/apps/kitty/kitty.app/bin:$PATH"
    export npm_config_cache="''${GOINFRE}/npm"
    export NIX_GOINFRE=1

    if [[ -o interactive && ! -d /nix/store && -z "''${NIX_ENTER_SKIP:-}" && -x "$HOME/.local/bin/nix-enter" ]]; then
      exec "$HOME/.local/bin/nix-enter"
    fi
  '';

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
