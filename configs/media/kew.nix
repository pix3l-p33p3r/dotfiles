{ config, pkgs, ... }:

{
  # Kew music player configuration
  # Kew is a terminal-based music player
  
  home.file = {
    ".config/kew/kewrc".source = ./kew/kewrc;
    ".config/kew/kewlibrary".source = ./kew/kewlibrary;
    ".config/kew/lastPlaylist.m3u".source = ./kew/lastPlaylist.m3u;
    
    # Catppuccin theme
    ".config/kew/themes/catppuccin.theme".source = ./kew/themes/catppuccin.theme;
    ".config/kew/themes/cyberpunk.theme".source = ./kew/themes/cyberpunk.theme;
  };
}

