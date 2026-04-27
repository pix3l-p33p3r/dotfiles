{ config, pkgs, lib, ... }:

{
  services.wayle = {
    enable = true;
    settings = {
      general = {
        font-mono = "JetBrainsMono Nerd Font";
        font-sans = "JetBrainsMono Nerd Font";
        tearing-mode = true;
      };

      styling = {
        theme-provider = "wayle";
        rounding = "sm";
        palette = {
          bg = "#1e1e2e";
          surface = "#313244";
          elevated = "#45475a";
          fg = "#cdd6f4";
          fg-muted = "#a6adc8";
          primary = "#b4befe";
          red = "#f38ba8";
          yellow = "#f9e2af";
          green = "#a6e3a1";
          blue = "#89b4fa";
        };
      };

      bar = {
        scale = 1.0;
        rounding = "sm";
        shadow = "none";
        border-location = "none";
        padding = 0.1;
        padding-ends = 1.1;
        button-icon-padding = 0.7;
        button-label-padding = 0.7;
        button-label-weight = "medium";
        button-rounding = "sm";
        layout = [
          {
            monitor = "*";
            left = [ "dashboard" "hyprland-workspaces" "window-title" ];
            center = [ "media" ];
            right = [
              "volume" "network"
              "custom-firewall" "custom-dns" "custom-hotspot"
              "bluetooth" "battery" "systray" "clock" "notification"
            ];
          }
        ];
      };

      modules = {
        clock = {
          format = "%H:%M";
          icon-name = "md-schedule-symbolic";
        };

        weather = {
          provider = "open-meteo";
          units = "metric";
          location = "Ben Guerir, Morocco";
        };

        hyprland-workspaces = {
          active-indicator = "underline";
          app-icons-show = false;
        };

        volume = {
          scroll-up = "wayle audio output-volume +5";
          scroll-down = "wayle audio output-volume -5";
        };

        dashboard = {
          dropdown-lock-command = "${pkgs.hyprlock}/bin/hyprlock";
        };

        custom = [
          {
            id = "firewall";
            command = "bash /home/pixel-peeper/dotfiles/scripts/firewall-status.sh";
            interval-ms = 5000;
            format = "{{ status }}";
            icon-name = "md-shield-symbolic";
            icon-map = { on = "md-shield-symbolic"; off = "md-shield-symbolic"; };
            left-click = "bash /home/pixel-peeper/dotfiles/scripts/firewall-toggle.sh";
            on-action = "bash /home/pixel-peeper/dotfiles/scripts/firewall-status.sh";
          }
          {
            id = "dns";
            command = "bash /home/pixel-peeper/dotfiles/scripts/dns-status.sh";
            interval-ms = 5000;
            format = "{{ status }}";
            icon-name = "md-dns-symbolic";
            icon-map = { filter = "md-dns-symbolic"; plain = "md-dns-symbolic"; };
            left-click = "bash /home/pixel-peeper/dotfiles/scripts/dns-toggle.sh";
            on-action = "bash /home/pixel-peeper/dotfiles/scripts/dns-status.sh";
            class-format = "{{ alt }}";
          }
          {
            id = "hotspot";
            command = "bash /home/pixel-peeper/dotfiles/scripts/hotspot-status.sh";
            interval-ms = 3000;
            format = "{{ status }}";
            icon-name = "md-wifi_tethering-symbolic";
            icon-map = { on = "md-wifi_tethering-symbolic"; off = "md-wifi_tethering_off-symbolic"; };
            left-click = "bash /home/pixel-peeper/dotfiles/scripts/hotspot-toggle.sh";
            right-click = "bash /home/pixel-peeper/dotfiles/scripts/hotspot-manage.sh";
            on-action = "bash /home/pixel-peeper/dotfiles/scripts/hotspot-status.sh";
          }
        ];
      };
    };
  };

  home.activation.wayleIcons = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v wayle &>/dev/null; then
      $DRY_RUN_CMD wayle icons install material \
        shield dns wifi_tethering wifi_tethering_off \
        volume_up wifi bluetooth battery_full \
        schedule notifications dashboard play_arrow \
        2>/dev/null || true
    fi
  '';
}
