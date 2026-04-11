{ pkgs, inputs, wallpaper, ... }:

let
  wallpaperPath = "${pkgs.copyPathToStore wallpaper}";
  avatarPath = "${pkgs.copyPathToStore (inputs.self + "/assets/avatar/ryuma.png")}";
  mochaConf = builtins.readFile ../../core/mocha.conf;

  # Full hyprlock config in-repo (no separate .conf). In '' strings, ''$ → literal $ for hyprlang ($text, $HOME, …).
  hyprlockConf = ''
    # Catppuccin Mocha + Style-10 layout (https://github.com/MrVivekRajan/Hyprlock-Styles/tree/main/Style-10)
    # Reference: https://github.com/catppuccin/hyprlock
    # Empty monitor = widgets follow the active output.
    source = ''$HOME/.config/hypr/mocha.conf

    ''$accent = ''$lavender
    ''$fontDisplay = Noto Sans
    ''$fontIcons = JetBrainsMono Nerd Font

    background {
        monitor =
        path = ${wallpaperPath}
        blur_passes = 2
        contrast = 0.8916
        brightness = 0.8172
        vibrancy = 0.1696
        vibrancy_darkness = 0.0
    }

    general {
        hide_cursor = true
        grace = 30
        ignore_empty_input = true
    }

    label {
        monitor =
        text = cmd[update:1000] echo "$(date +"%A")"
        color = ''$text
        font_size = 90
        font_family = ''$fontDisplay
        font_weight = bold
        position = 0, 350
        halign = center
        valign = center
        opacity = 0.85
    }

    label {
        monitor =
        text = cmd[update:1000] echo "$(date +"%d %B")"
        color = ''$text
        font_size = 40
        font_family = ''$fontDisplay
        font_weight = bold
        position = 0, 250
        halign = center
        valign = center
        opacity = 0.85
    }

    label {
        monitor =
        text = cmd[update:1000] echo " $(date +'- %I:%M -') "
        color = ''$text
        font_size = 20
        font_family = ''$fontDisplay
        font_weight = bold
        position = 0, 190
        halign = center
        valign = center
        opacity = 0.85
    }

    image {
        monitor =
        path = ${avatarPath}
        border_size = 2
        border_color = ''$accent
        size = 130
        rounding = -1
        rotate = 0
        reload_time = -1
        reload_cmd =
        position = 0, 40
        halign = center
        valign = center
    }

    shape {
        monitor =
        size = 300, 60
        color = rgba(49, 50, 68, 0.72)
        rounding = -1
        border_size = 0
        border_color = rgba(255, 255, 255, 0)
        rotate = 0
        xray = false
        position = 0, -130
        halign = center
        valign = center
    }

    label {
        monitor =
        text = cmd[update:60000] echo "''$USER"
        color = ''$text
        font_size = 18
        font_family = ''$fontDisplay
        font_weight = bold
        position = 0, -130
        halign = center
        valign = center
        opacity = 0.9
    }

    input-field {
        monitor =
        size = 300, 60
        outline_thickness = 2
        dots_size = 0.2
        dots_spacing = 0.2
        dots_center = true
        outer_color = rgba(255, 255, 255, 0)
        inner_color = rgba(69, 71, 90, 0.65)
        font_color = ''$text
        fade_on_empty = false
        font_family = ''$fontDisplay
        placeholder_text = Enter password
        hide_input = false
        position = 0, -210
        halign = center
        valign = center
    }

    label {
        monitor =
        text = 󰜉
        color = ''$subtext0
        font_size = 40
        font_family = ''$fontIcons
        onclick = reboot now
        position = 0, 100
        halign = center
        valign = bottom
        opacity = 0.85
    }

    label {
        monitor =
        text = 󰐥
        color = ''$subtext0
        font_size = 40
        font_family = ''$fontIcons
        onclick = shutdown now
        position = 336, 100
        halign = center
        valign = bottom
        opacity = 0.85
    }

    label {
        monitor =
        text = 󰤄
        color = ''$subtext0
        font_size = 40
        font_family = ''$fontIcons
        onclick = systemctl suspend
        position = -336, 100
        halign = center
        valign = bottom
        opacity = 0.85
    }
  '';
in
{
  xdg.configFile."hypr/mocha.conf" = {
    text = mochaConf;
    force = true;
  };

  xdg.configFile."hypr/hyprlock.conf" = {
    text = hyprlockConf;
    force = true;
  };

  programs.hyprlock.enable = false;
}
