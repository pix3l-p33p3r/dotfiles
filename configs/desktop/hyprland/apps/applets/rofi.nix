{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    
    # Configuration options
    extraConfig = {
      # Display modes
      modi = "run,window,combi";
      
      # Display settings
      show-icons = true;
      icon-theme = "Papirus-Dark";
      display-drun = "Applications";
      display-run = "Run";
      display-window = "Windows";
      display-ssh = "SSH";
      display-combi = "All";
      
      # Window settings
      width = 600;
      lines = 5;
      columns = 2;
      font = "JetBrainsMono Nerd Font 18";
      
      # Behavior
      combi-hide-mode-prefix = true;
      disable-history = false;
      sort = true;
      sorting-method = "fzf";
      case-sensitive = false;
      cycle = true;
      
      # Appearance
      sidebar-mode = true;
      eh = 1;
      auto-select = false;
      parse-hosts = true;
      parse-known-hosts = true;
      hide-scrollbar = true;
      location = 0;
      
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
      drun-display-format = "{icon} {name}";
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
