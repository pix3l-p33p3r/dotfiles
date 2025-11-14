{ pkgs, inputs, wallpaper, ... }:

let
  # Avatar path
  avatar = "${inputs.self}/assets/avatar/ryuma_pixel-peeper.png";
in
{
  home.packages = [ pkgs.hyprlock ];

  # Official Catppuccin hyprlock theme configuration
  # Based on: https://github.com/catppuccin/hyprlock
  # Colors from: https://github.com/catppuccin/hyprland
  xdg.configFile."hyprlock/hyprlock.conf" = {
    text = ''
      # Catppuccin Mocha Color Definitions
      # Official theme from: https://github.com/catppuccin/hyprland
      $rosewater = rgb(f5e0dc)
      $rosewaterAlpha = f5e0dc
      $flamingo = rgb(f2cdcd)
      $flamingoAlpha = f2cdcd
      $pink = rgb(f5c2e7)
      $pinkAlpha = f5c2e7
      $mauve = rgb(cba6f7)
      $mauveAlpha = cba6f7
      $red = rgb(f38ba8)
      $redAlpha = f38ba8
      $maroon = rgb(eba0ac)
      $maroonAlpha = eba0ac
      $peach = rgb(fab387)
      $peachAlpha = fab387
      $yellow = rgb(f9e2af)
      $yellowAlpha = f9e2af
      $green = rgb(a6e3a1)
      $greenAlpha = a6e3a1
      $teal = rgb(94e2d5)
      $tealAlpha = 94e2d5
      $sky = rgb(89dceb)
      $skyAlpha = 89dceb
      $sapphire = rgb(74c7ec)
      $sapphireAlpha = 74c7ec
      $blue = rgb(89b4fa)
      $blueAlpha = 89b4fa
      $lavender = rgb(b4befe)
      $lavenderAlpha = b4befe
      $text = rgb(cdd6f4)
      $textAlpha = cdd6f4
      $subtext1 = rgb(bac2de)
      $subtext1Alpha = bac2de
      $subtext0 = rgb(a6adc8)
      $subtext0Alpha = a6adc8
      $overlay2 = rgb(9399b2)
      $overlay2Alpha = 9399b2
      $overlay1 = rgb(7f849c)
      $overlay1Alpha = 7f849c
      $overlay0 = rgb(6c7086)
      $overlay0Alpha = 6c7086
      $surface2 = rgb(585b70)
      $surface2Alpha = 585b70
      $surface1 = rgb(45475a)
      $surface1Alpha = 45475a
      $surface0 = rgb(313244)
      $surface0Alpha = 313244
      $base = rgb(1e1e2e)
      $baseAlpha = 1e1e2e
      $mantle = rgb(181825)
      $mantleAlpha = 181825
      $crust = rgb(11111b)
      $crustAlpha = 11111b
      
      # Accent and font customization
      $accent = $lavender
      $accentAlpha = $lavenderAlpha
      $font = JetBrainsMono Nerd Font
      
      # GENERAL
      general {
          hide_cursor = true
          grace = 30
          ignore_empty_input = true
      }
      
      # BACKGROUND
      background {
          monitor = eDP-1
          path = ${wallpaper}
          blur_passes = 3
          blur_size = 7
          noise = 0.02
          contrast = 1.3
          brightness = 0.8
          vibrancy = 0.21
          color = $base
      }
      
      # TIME
      label {
          monitor = eDP-1
          text = cmd[update:1000] date "+%H:%M:%S"
          color = $text
          font_size = 50
          font_family = $font
          position = -100, 70
          halign = right
          valign = bottom
      }
      
      # DATE
      label {
          monitor = eDP-1
          text = cmd[update:1000] date "+%A, %d %B %Y"
          color = $subtext1
          font_size = 18
          font_family = $font
          position = -100, 160
          halign = right
          valign = bottom
      }
      
      # USERNAME
      label {
          monitor = eDP-1
          text = $USER
          color = $subtext1
          font_size = 18
          font_family = $font
          position = -100, 200
          halign = right
          valign = bottom
      }
      
      # USER AVATAR
      image {
          monitor = eDP-1
          path = ${avatar}
          size = 250
          rounding = 120
          border_size = 3
          border_color = $accent
          position = 0, 75
          halign = center
          valign = center
      }
      
      # INPUT FIELD
      input-field {
          monitor = eDP-1
          size = 180, 45
          outline_thickness = 2
          dots_size = 0.28
          dots_spacing = 0.12
          dots_center = true
          dots_rounding = -1
          outer_color = $accent
          inner_color = $surface0
          font_color = $text
          fade_on_empty = true
          fade_timeout = 800
          placeholder_text = <i>Input Password...</i>
          hide_input = false
          rounding = 40
          check_color = $accent
          fail_color = $red
          fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
          fail_transition = 250
          capslock_color = $yellow
          numlock_color = -1
          bothlock_color = -1
          invert_numlock = false
          swap_font_color = false
          position = 0, -140
          halign = center
          valign = center
      }
    '';
    force = true;
  };
}


