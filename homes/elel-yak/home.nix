{
  config,
  pkgs,
  lib,
  antigravity,
  ...
}:
{
  imports = [
    ./modules/packages.nix
    ./modules/shell.nix
    ./modules/desktop.nix
    ./modules/antigravity.nix
  ];

  home.username = "elel-yak";
  home.homeDirectory = "/home/elel-yak";
  home.stateVersion = "24.11";

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  # Goinfre-friendly XDG (matches cluster ~/.zshenv)
  xdg.enable = true;
  xdg.cacheHome = "/goinfre/elel-yak/cache";
  xdg.dataHome = "/goinfre/elel-yak/xdg-data";
  xdg.stateHome = "/goinfre/elel-yak/xdg-state";

  home.sessionVariables = {
    GOINFRE = "/goinfre/elel-yak";
    EDITOR = "nvim";
    VISUAL = "nvim";
    npm_config_cache = "/goinfre/elel-yak/npm";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.nix-profile/bin"
  ];

  # Don't clobber existing zap-managed interactive zsh; only ensure profile PATH.
  programs.bash.enable = true;
}
