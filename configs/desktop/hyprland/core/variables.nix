{ pkgs, inputs, wallpaper, ... }:
{
  kitty = "${pkgs.kitty}/bin/kitty";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";

  volume_up = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
  volume_down = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
  volume_mute_toggle = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
  player_play_toggle = "${pkgs.playerctl}/bin/playerctl play-pause";
  player_next = "${pkgs.playerctl}/bin/playerctl next";
  player_prev = "${pkgs.playerctl}/bin/playerctl previous";

  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  pidof = "${pkgs.procps}/bin/pidof";

  notify-send = "${pkgs.libnotify}/bin/notify-send";
  screen_brightness_up = ''${pkgs.brightnessctl}/bin/brightnessctl set +5% && ${pkgs.libnotify}/bin/notify-send "Brightness" "Brightness: $(${pkgs.brightnessctl}/bin/brightnessctl | grep -Eo '[0-9]+%')"'';
  screen_brightness_down = ''${pkgs.brightnessctl}/bin/brightnessctl set 5%- && ${pkgs.libnotify}/bin/notify-send "Brightness" "Brightness: $(${pkgs.brightnessctl}/bin/brightnessctl | grep -Eo '[0-9]+%')"'';

  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";

  snaparea = "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | tee ~/Pictures/Screenshots/$(date +%Y%m%d_%Hh%Mm%Ss)_area.png | ${pkgs.wl-clipboard}/bin/wl-copy -t 'image/png'";
  snapfull = "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp -o)\" - | tee ~/Pictures/Screenshots/$(date +%Y%m%d_%Hh%Mm%Ss)_full.png | ${pkgs.wl-clipboard}/bin/wl-copy -t 'image/png'";

  wofi = "${pkgs.wofi}/bin/wofi";
  menu = "${pkgs.wofi}/bin/wofi --show drun";
  sherlock = "${inputs.sherlock.packages.x86_64-linux.default}/bin/sherlock";
  firefox = "${pkgs.firefox}/bin/firefox";
  thunar = "${pkgs.xfce.thunar}/bin/thunar";

  waybar = "${pkgs.waybar}/bin/waybar";

  wl-clip-persist = "${pkgs.wl-clip-persist}/bin/wl-clip-persist";

  wallpaper = "${pkgs.copyPathToStore wallpaper}";
  cliphist = "${pkgs.cliphist}/bin/cliphist";
  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";

  swaync = "${pkgs.swaynotificationcenter}/bin/swaync";
  swaync-client = "${pkgs.swaynotificationcenter}/bin/swaync-client";
}
