{ variables, ... }:
let
  inherit (variables) 
	loginctl cliphist rofi rofi-menu rofi-cliphist hyprpicker volume_up volume_down 
	volume_mute_toggle player_play_toggle player_next player_prev 
	screen_brightness_up screen_brightness_down wl-paste wl-clip-persist wl-copy
	hyprpanel hyprlock hypridle hyprpaper;
in
{
  exec-once = [

	# Services
	"systemctl --user restart pipewire pipewire.socket"
	"systemctl --user is-active xdg-desktop-portal-gtk.service && systemctl --user stop xdg-desktop-portal-gtk.service"
	"systemctl --user is-active xdg-desktop-portal-hyprland.service && systemctl --user stop xdg-desktop-portal-hyprland.service"
	"systemctl --user restart xdg-desktop-portal.service"

	# Applets
	"${hyprpaper}"
	"${hyprpanel}"
	"${hypridle}"
	
	# Clipboard
	"sleep 3; ${cliphist} wipe"
	"${wl-paste} --watch ${cliphist} store"
	"${wl-clip-persist} --clipboard both"

	# Terminal
	"$terminal"

  ];

  bindm = [
	"ALT,mouse:272,movewindow"
	"ALT_SHIFT,mouse:272,resizewindow"
  ];

  bind = [
	"$mod, Return, exec, $terminal"
  "$mod SHIFT, Return, exec, $terminal --class kitty-float"
	"$mod, q, killactive,"
	"$mod, M, exit,"
  "$mod SHIFT, space, togglefloating,"
	"$mod, space, exec, ${rofi-menu}"
  "$mod SHIFT, v, exec, ${cliphist} list | sort -r | ${rofi-cliphist} | ${cliphist} decode | ${wl-copy}"
  "$mod SHIFT, c, exec, ${hyprpicker} | ${wl-copy}"
  "$mod SHIFT, d, exec, ${rofi} -show run"

	# Hyprpanel windows
	"$mod, p, exec, ${hyprpanel} toggleWindow dashboardmenu"

	"$mod, f, exec, $file_manager"
	"$mod, b, exec, $browser"
	"$mod, x, exec, $browser --new-tab https://x.com"
	"$mod, g, exec, $browser --new-tab https://mail.google.com"
	"$mod, c, exec, cursor"
	"$mod, v, exec, vesktop"

	"$mod, l, movefocus, r"
	"$mod, h, movefocus, l"
	"$mod, k, movefocus, u"
	"$mod, j, movefocus, d"

	"$mod SHIFT, l, movewindow, r"
	"$mod SHIFT, h, movewindow, l"
	"$mod SHIFT, k, movewindow, u"
	"$mod SHIFT, j, movewindow, d"

	"$mod, 1, workspace, 1"
	"$mod, 2, workspace, 2"
	"$mod, 3, workspace, 3"
	"$mod, 4, workspace, 4"
	"$mod, 5, workspace, 5"
	"$mod, 6, workspace, 6"
	"$mod, 7, workspace, 7"
	"$mod, 8, workspace, 8"
	"$mod, 9, workspace, 9"
	"$mod, 0, workspace, 10"

	"$mod, Escape, exec, ${hyprlock}"

	"$mod SHIFT, 1, movetoworkspace, 1"
	"$mod SHIFT, 2, movetoworkspace, 2"
	"$mod SHIFT, 3, movetoworkspace, 3"
	"$mod SHIFT, 4, movetoworkspace, 4"
	"$mod SHIFT, 5, movetoworkspace, 5"
	"$mod SHIFT, 6, movetoworkspace, 6"
	"$mod SHIFT, 7, movetoworkspace, 7"
	"$mod SHIFT, 8, movetoworkspace, 8"
	"$mod SHIFT, 9, movetoworkspace, 9"
	"$mod SHIFT, 0, movetoworkspace, 10"

	"$mod SHIFT, f, fullscreen, 0"

	"$mod, S, togglespecialworkspace, magic"
	"$mod SHIFT, S, movetoworkspace, special:magic"

	# Multimedia
	",XF86AudioRaiseVolume, exec, ${volume_up}"
	",XF86AudioLowerVolume, exec, ${volume_down}"
	",XF86AudioMute, exec, ${volume_mute_toggle}"
	",XF86AudioPlay, exec, ${player_play_toggle}"
	",XF86AudioNext, exec, ${player_next}"
	",XF86AudioPrev, exec, ${player_prev}"

	# Brightness controls
	",XF86MonBrightnessUp, exec, ${screen_brightness_up}"
	",XF86MonBrightnessDown, exec, ${screen_brightness_down}"
  ];
}
