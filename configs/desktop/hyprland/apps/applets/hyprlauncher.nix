{ pkgs, ... }:
{
  programs.hyprlauncher = {
    enable = true;

    settings = {
      # General settings
      width = 600;
      height = 400;
      border_radius = 12;
      border_width = 2;
      padding = 20;
      spacing = 8;
      
      # Font settings
      font_family = "FiraCode Nerd Font";
      font_size = 14;
      
      # Animation settings
      animation_duration = 200;
      animation_type = "slide";
      
      # Behavior settings
      case_sensitive = false;
      fuzzy_search = true;
      max_results = 10;
      
      # Catppuccin Mocha Colors
      colors = {
        # Base colors
        background = "#1e1e2e";           # Base
        foreground = "#cdd6f4";           # Text
        border = "#cba6f7";              # Mauve
        
        # Selection colors
        selection_background = "#313244"; # Surface0
        selection_foreground = "#cdd6f4"; # Text
        
        # Input colors
        input_background = "#313244";    # Surface0
        input_foreground = "#cdd6f4";    # Text
        input_border = "#585b70";        # Surface1
        
        # Result colors
        result_background = "transparent";
        result_foreground = "#cdd6f4";   # Text
        result_hover_background = "#313244"; # Surface0
        result_hover_foreground = "#cdd6f4"; # Text
        
        # Accent colors
        accent = "#cba6f7";              # Mauve
        accent_hover = "#a6e3a1";         # Green
        
        # Status colors
        success = "#a6e3a1";             # Green
        warning = "#f9e2af";             # Yellow
        error = "#f38ba8";               # Red
        info = "#89b4fa";                # Blue
      };
      
      # Keybindings
      keybindings = {
        "Escape" = "close";
        "Ctrl+c" = "close";
        "Return" = "select";
        "Tab" = "select";
        "Up" = "up";
        "Down" = "down";
        "Ctrl+p" = "up";
        "Ctrl+n" = "down";
        "Ctrl+u" = "clear";
        "Ctrl+w" = "delete_word";
        "Ctrl+a" = "home";
        "Ctrl+e" = "end";
      };
      
      # Applications to include
      applications = {
        terminal = "kitty";
        browser = "firefox";
        file_manager = "thunar";
        editor = "nvim";
        image_viewer = "imv";
        pdf_viewer = "zathura";
        music_player = "spotify";
        video_player = "mpv";
      };
      
      # Custom commands
      custom_commands = [
        {
          name = "Lock Screen";
          command = "hyprlock";
          icon = "lock";
          category = "system";
        }
        {
          name = "Shutdown";
          command = "systemctl poweroff";
          icon = "power";
          category = "system";
        }
        {
          name = "Reboot";
          command = "systemctl reboot";
          icon = "restart";
          category = "system";
        }
        {
          name = "Suspend";
          command = "systemctl suspend";
          icon = "sleep";
          category = "system";
        }
        {
          name = "Color Picker";
          command = "hyprpicker -a";
          icon = "color";
          category = "utilities";
        }
        {
          name = "Screenshot";
          command = "hyprshot -m output";
          icon = "camera";
          category = "utilities";
        }
        {
          name = "Screenshot Area";
          command = "hyprshot -m region";
          icon = "camera";
          category = "utilities";
        }
      ];
      
      # Categories
      categories = {
        "system" = {
          icon = "settings";
          color = "#f38ba8"; # Red
        };
        "utilities" = {
          icon = "tools";
          color = "#f9e2af"; # Yellow
        };
        "development" = {
          icon = "code";
          color = "#89b4fa"; # Blue
        };
        "multimedia" = {
          icon = "media";
          color = "#cba6f7"; # Mauve
        };
        "office" = {
          icon = "document";
          color = "#94e2d5"; # Teal
        };
        "games" = {
          icon = "gamepad";
          color = "#a6e3a1"; # Green
        };
      };
    };
  };
}
