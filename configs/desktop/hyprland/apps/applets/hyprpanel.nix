{ config, pkgs, ... }:

{
  # hyprpanel configuration is managed through the config/ subdirectory
  # Config files are symlinked to ~/.config/hyprpanel/
  
  home.file = {
    ".config/hyprpanel/config.json".source = ./hyprpanel/config/config.json;
    ".config/hyprpanel/modules.json".source = ./hyprpanel/config/modules.json;
    ".config/hyprpanel/modules.scss".source = ./hyprpanel/config/modules.scss;
  };
}

