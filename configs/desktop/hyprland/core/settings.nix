{ variables, keybindings, ... }:
let
  inherit (variables) kitty thunar firefox menu;
  inherit (keybindings) exec-once bindm bind;
in
{
  "$mod" = "SUPER";
  "$terminal" = kitty;
  "$file_manager" = thunar;
  "$browser" = firefox;
  "$menu" = menu;

  "$left" = "h";
  "$right" = "l";
  "$up" = "k";
  "$down" = "j";

  inherit exec-once bindm bind;

  general = {
    gaps_out = 2;
    gaps_in = "2,2,2,2";
    layout = "dwindle";
  };

  monitor = [ "eDP-1,preferred,auto,1,bitdepth,8" ];

  decoration = {
    blur = {
      enabled = false;
    };
    # shadow = {
    #   enabled = false;
    # };
    rounding = 5;
  };

  misc = {
    disable_hyprland_logo = true;
    force_default_wallpaper = 0;
    vfr = true;
    font_family = "JetBrainsMono Nerd Font";
    mouse_move_enables_dpms = true;
    key_press_enables_dpms = true;
  };

  gesture = [
    "3, horizontal, workspace"
  ];

  animations = {
    enabled = true;
  };

  input = {
    kb_layout = "us";
    repeat_rate = 35;
    repeat_delay = 300;

    sensitivity = 0.2;
    accel_profile = "flat";
    force_no_accel = true;

    mouse_refocus = false;
    follow_mouse = 0;

    touchpad = {
      disable_while_typing = true;
      natural_scroll = true;
      tap-to-click = true;
    };
  };

  cursor = {
    hide_on_key_press = true;
    no_hardware_cursors = true;
  };

  # plugins = [ ];
  windowrulev2 = [
    "workspace 2,class:firefox"

    "float,class:alacritty-float"
    "center,class:alacritty-float"
    "size 900 600,class:alacritty-float"

    "float,class:.blueman-manager-wrapped"

    "float,class:org.gnome.seahorse.Application"
    "size 900 700,class:org.gnome.seahorse.Application"

    "float,class:[tT]hunar"
    "size 900 600,class:[tT]hunar"

    "float,class:nm-connection-editor"
    "size 900 600,class:nm-connection-editor"

    "float,class:org.pulseaudio.pavucontrol"
    "size 900 600,class:org.pulseaudio.pavucontrol"

    "float,class:pavucontrol"
    "center,class:pavucontrol"
    "size 700 500,class:pavucontrol"

    "idleinhibit focus,class:mpv"
    "idleinhibit focus,class:org.pwmt.zathura"
  ];
}
