{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    
    # Configuration options
    extraConfig = {
      # Display modes
      modi = "drun,run,window,ssh";
      
      # Display settings
      show-icons = true;
      icon-theme = "Papirus-Dark";
      display-drun = "Applications";
      display-run = "Run";
      display-window = "Windows";
      display-ssh = "SSH";
      
      # Window settings
      width = 550;
      lines = 8;
      columns = 1;
      font = "Noto Sans 12";
      
      # Behavior
      combi-hide-mode-prefix = true;
      disable-history = false;
      sort = true;
      sorting-method = "fzf";
      case-sensitive = false;
      cycle = true;
      
      # Appearance
      sidebar-mode = false;
      eh = 1;
      auto-select = false;
      parse-hosts = true;
      parse-known-hosts = true;
      
      # Terminal
      terminal = "${pkgs.kitty}/bin/kitty";
      
      # Prompt
      prompt = "Search";
      
      # Filtering
      # filter = "fuzzy";
      # fuzzy-filter = "fzf";
      
      # Click behavior
      click-to-exit = true;
      
      # Wayland specific
      drun-display-format = "{name}";
      window-format = "{w} {c} {t}";
    };
    
    # Plugin configuration
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
      rofi-power-menu
    ];
  };
}
