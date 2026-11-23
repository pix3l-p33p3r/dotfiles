{
  config,
  pkgs,
  lib,
  antigravity,
  codex-desktop-linux,
  ...
}:
{
  imports = [
    ./modules/packages.nix
    ./modules/shell.nix # kitty.conf stays a real file; do not enable programs.kitty
    ./modules/desktop.nix
    ./modules/theming.nix
    ./modules/antigravity.nix
    ./modules/codex.nix
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
    ELAN_HOME = "/goinfre/elel-yak/elan";
    EDITOR = "nvim";
    VISUAL = "nvim";
    npm_config_cache = "/goinfre/elel-yak/npm";
    # ocl-icd + Khronos loader: rusticl (Mesa) + intel-neo from the HM profile
    OCL_ICD_VENDORS = "${config.home.profileDirectory}/etc/OpenCL/vendors";
    OPENCL_VENDOR_PATH = "${config.home.profileDirectory}/etc/OpenCL/vendors";
    # Enable rusticl on AMD (radeonsi) + Intel (iris). AMD needs kernel DRM
    # new enough for the nixpkgs mesa (see README / RT notes on 5.15).
    RUSTICL_ENABLE = "radeonsi,iris";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.nix-profile/bin"
    "/goinfre/elel-yak/elan/bin"
  ];

  # Don't clobber existing zap-managed interactive zsh; only ensure profile PATH.
  programs.bash.enable = true;

  # Antigravity IDE (and other Electron FHS apps) replace /usr inside bwrap,
  # so host /usr/share/fonts vanish. Nix fonts under the profile stay visible.
  fonts.fontconfig.enable = true;
}
