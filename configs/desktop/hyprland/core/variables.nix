{ pkgs, inputs, wallpaper, ... }:
{
  # Terminal and core applications
  kitty = "${pkgs.kitty}/bin/kitty";
  thunar = "${pkgs.xfce.thunar}/bin/thunar";
  firefox = "${pkgs.firefox}/bin/firefox";

  # Audio control
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  volume_up = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
  volume_down = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
  volume_mute_toggle = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
  player_play_toggle = "${pkgs.playerctl}/bin/playerctl play-pause";
  player_next = "${pkgs.playerctl}/bin/playerctl next";
  player_prev = "${pkgs.playerctl}/bin/playerctl previous";

  # System control
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  pidof = "${pkgs.procps}/bin/pidof";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  screen_brightness_up = ''${pkgs.brightnessctl}/bin/brightnessctl set +5% && ${pkgs.libnotify}/bin/notify-send "Brightness" "Brightness: $(${pkgs.brightnessctl}/bin/brightnessctl | grep -Eo '[0-9]+%')"'';
  screen_brightness_down = ''${pkgs.brightnessctl}/bin/brightnessctl set 5%- && ${pkgs.libnotify}/bin/notify-send "Brightness" "Brightness: $(${pkgs.brightnessctl}/bin/brightnessctl | grep -Eo '[0-9]+%')"'';

  # Screenshot utilities
  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
  snaparea = "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | tee ~/Pictures/Screenshots/$(date +%Y%m%d_%Hh%Mm%Ss)_area.png | ${pkgs.wl-clipboard}/bin/wl-copy -t 'image/png'";
  snapfull = "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp -o)\" - | tee ~/Pictures/Screenshots/$(date +%Y%m%d_%Hh%Mm%Ss)_full.png | ${pkgs.wl-clipboard}/bin/wl-copy -t 'image/png'";

  # Application launchers and menus
  wofi = "${pkgs.wofi}/bin/wofi";
  menu = "${pkgs.wofi}/bin/wofi --show drun";
  hyprlauncher = "${pkgs.hyprlauncher}/bin/hyprlauncher";

  # Hyprland ecosystem
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
  hyprpanel = "${pkgs.hyprpanel}/bin/hyprpanel";
  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";
  hypridle = "${pkgs.hypridle}/bin/hypridle";
  hyprpaper = "${pkgs.hyprpaper}/bin/hyprpaper";
  hyprshot = "${pkgs.hyprshot}/bin/hyprshot";
  hyprsunset = "${pkgs.hyprsunset}/bin/hyprsunset";
  hyprutils = "${pkgs.hyprutils}/bin/hyprutils";

  # Clipboard and utilities
  wl-clip-persist = "${pkgs.wl-clip-persist}/bin/wl-clip-persist";
  cliphist = "${pkgs.cliphist}/bin/cliphist";
  wallpaper = "${pkgs.copyPathToStore wallpaper}";
}
