{ inputs, wallpaper, pkgs, ... }@all: {
   imports = [
   ../../configs/desktop/hyprland
   ./catppuccin.nix
   ];

   # Essential for Thunar for trash, network, and mounting
   # services.gvfs.enable = true; this was the old way 
   xdg.portal.enable = true;

   programs.zsh.enable = true;

   programs.nix-search-tv.enable = true;

   nixpkgs.config.allowUnfree = true;

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

   home.username = "pixel-peeper";
   home.homeDirectory = "/home/pixel-peeper";
   home.stateVersion = "25.05";
}
