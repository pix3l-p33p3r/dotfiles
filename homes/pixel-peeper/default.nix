{ inputs, wallpaper, pkgs, lib, ... }@all: {
  imports = [
    ../../configs/desktop/hyprland
    ../../configs/editors/cursor-config.nix
    ./catppuccin.nix
    ./sops.nix
  ];

  # Essential for Thunar for trash, network, and mounting
  # services.gvfs.enable = true; this was the old way 
  xdg.portal.enable = true;

  programs.zsh.enable = true;

  programs.nix-search-tv.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Required for home-manager nix configuration
  nix.package = lib.mkDefault pkgs.nix;

  programs.atuin.enable = true;
  programs.home-manager.enable = true;

  # Zen Browser (twilight) enabled; Firefox remains default browser
  programs.zen-browser = {
    enable = true;
    # No spaces/containers for now
    profiles.default = {
      # TODO: add extensions via extensions.packages once source list is decided
      extensions.packages = [];
    };
  };

  # Install Cursor AI Editor v2.0.34 (using custom AppImage wrapper)
  home.packages = [
    (pkgs.callPackage ../../configs/editors/cursor.nix {})
  ];

  home.username = "pixel-peeper";
  home.homeDirectory = "/home/pixel-peeper";
  home.stateVersion = "25.05";
}
