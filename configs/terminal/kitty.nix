{ pkgs, lib, ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = lib.mkForce "FiraCode Nerd Font";
      size = lib.mkForce 13;
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

      # Tab settings
      tab_bar_align = "left";
      tab_fade = "0.15 0.35 0.65 1";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";

      # Background blur
      background_blur = 1;
      background_opacity = lib.mkForce "0.8";

      clipboard_control = "write-clipboard write-primary read-clipboard-ask read-primary-ask";
      allow_hyperlinks = "yes";
      shell_integration = "enabled";
      allow_cloning = "ask";
      notify_on_cmd_finish = "unfocused 10.0 bell";
    };
    extraConfig = ''
      # Symbol mapping for powerline
      symbol_map U+E0A0-U+E0A3,U+E0C0-U+E0C7 PowerlineSymbols
      text_composition_strategy platform

      # Catppuccin Mocha Colorscheme
      # Base colors
      background #1e1e2e
      foreground #cdd6f4
      selection_background #585b70
      selection_foreground #cdd6f4
      url_color #f5e0dc

      # Cursor colors
      cursor #f5e0dc
      cursor_text_color #1e1e2e

      # Normal colors
      color0 #45475a
      color1 #f38ba8
      color2 #a6e3a1
      color3 #f9e2af
      color4 #89b4fa
      color5 #cba6f7
      color6 #94e2d5
      color7 #bac2de

      # Bright colors
      color8 #585b70
      color9 #f38ba8
      color10 #a6e3a1
      color11 #f9e2af
      color12 #89b4fa
      color13 #cba6f7
      color14 #94e2d5
      color15 #a6adc8

      # Tab bar colors
      tab_bar_background #11111b
      active_tab_background #cba6f7
      active_tab_foreground #11111b
      inactive_tab_background #313244
      inactive_tab_foreground #a6adc8
      tab_bar_margin_color #11111b
    '';
  };
}
