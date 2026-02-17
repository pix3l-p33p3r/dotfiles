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
  windowrule = [
    "float on, match:class kitty-float"
    "center on, match:class kitty-float"
    "size 900 600, match:class kitty-float"

    "float on, match:class .blueman-manager-wrapped"

    "float on, match:class org.gnome.seahorse.Application"
    "size 900 700, match:class org.gnome.seahorse.Application"

    "tile on, match:class [tT]hunar"

    "float on, match:class nm-connection-editor"
    "size 900 600, match:class nm-connection-editor"

    "float on, match:class org.pulseaudio.pavucontrol"
    "size 900 600, match:class org.pulseaudio.pavucontrol"

    "float on, match:class pavucontrol"
    "center on, match:class pavucontrol"
    "size 700 500, match:class pavucontrol"

    "idle_inhibit focus, match:class mpv"
    "idle_inhibit focus, match:class org.pwmt.zathura"
  ];
}
