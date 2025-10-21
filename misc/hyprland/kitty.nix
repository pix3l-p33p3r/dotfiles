{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font Mono";
      size = 16;
    };
    settings = {
      # Cursor trail
      cursor_trail = 1;
      cursor_trail_decay = "0.15 0.3";
      cursor_trail_start_threshold = 2;
      mouse_hide_wait = 2.0;

      # URLs
      url_color = "#0087bd";
      url_style = "curly";
      detect_urls = "yes";
      show_hyperlink_targets = "yes";
      underline_hyperlinks = "always";

      # Trailing spaces
      strip_trailing_spaces = "always";

      # Bell
      enable_audio_bell = "yes";
      visual_bell_duration = 0.0;
      window_alert_on_bell = "yes";
      bell_on_tab = "🔔 ";

      # Window settings
      remember_window_size = "yes";
      remember_window_position = "no";
      window_border_width = "5pt";
      draw_minimal_borders = "yes";
      window_margin_width = 0;
      single_window_margin_width = 1;
      window_padding_width = 1;
      single_window_padding_width = 1;
      placement_strategy = "center";
      inactive_text_alpha = 0.5;
      tab_bar_align = "center";
      tab_fade = "0.15 0.35 0.65 1";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";

      # Background blur
      background_blur = 1;
      background_opacity = 0.8;

      clipboard_control = "write-clipboard write-primary read-clipboard-ask read-primary-ask";
      allow_hyperlinks = "yes";
      shell_integration = "enabled";
      allow_cloning = "ask";
      notify_on_cmd_finish = "unfocused 10.0 bell";

      # Catppuccin Mocha Theme Colors
      foreground = "#CDD6F4";
      background = "#1E1E2E";
      selection_foreground = "#1E1E2E";
      selection_background = "#F5E0DC";

      # Cursor colors
      cursor = "#F5E0DC";
      cursor_text_color = "#1E1E2E";

      # URL underline color
      url_color = "#F5E0DC";

      # Window border colors
      active_border_color = "#B4BEFE";
      inactive_border_color = "#6C7086";
      bell_border_color = "#F9E2AF";

      # Tab bar colors
      active_tab_foreground = "#11111B";
      active_tab_background = "#CBA6F7";
      inactive_tab_foreground = "#CDD6F4";
      inactive_tab_background = "#181825";
      tab_bar_background = "#11111B";

      # Mark colors
      mark1_foreground = "#1E1E2E";
      mark1_background = "#B4BEFE";
      mark2_foreground = "#1E1E2E";
      mark2_background = "#CBA6F7";
      mark3_foreground = "#1E1E2E";
      mark3_background = "#74C7EC";

      # Terminal colors
      color0 = "#45475A";
      color1 = "#F38BA8";
      color2 = "#A6E3A1";
      color3 = "#F9E2AF";
      color4 = "#89B4FA";
      color5 = "#F5C2E7";
      color6 = "#94E2D5";
      color7 = "#BAC2DE";
      color8 = "#585B70";
      color9 = "#F38BA8";
      color10 = "#A6E3A1";
      color11 = "#F9E2AF";
      color12 = "#89B4FA";
      color13 = "#F5C2E7";
      color14 = "#94E2D5";
      color15 = "#A6ADC8";
    };
    extraConfig = ''
      # Symbol mapping for powerline
      symbol_map U+E0A0-U+E0A3,U+E0C0-U+E0C7 PowerlineSymbols
      text_composition_strategy platform
    '';
  };
}
