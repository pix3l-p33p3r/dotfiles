{ config, pkgs, lib, ... }:

let
  systemctl = lib.getExe' pkgs.systemd "systemctl";
in
{
  services.wayle = {
    enable = true;
    settings = {
      styling = {
        theme-provider = "wayle";
        palette = {
          bg = "#1e1e2e";
          surface = "#313244";
          elevated = "#45475a";
          fg = "#cdd6f4";
          fg_muted = "#a6adc8";
          primary = "#b4befe";
          red = "#f38ba8";
          yellow = "#f9e2af";
          green = "#a6e3a1";
          blue = "#89b4fa";
        };
      };

      bar = {
        auto-hide = "fullscreen";
        rounding = "lg";
        layout = [
          {
            monitor = "*";
            left = [ "dashboard" "hyprland-workspaces" "hyprland-windowtitle" ];
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
          unit = "metric";
          location = "Ben Guerir, Morocco";
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

  home.activation.wayleWeatherConfig = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
    SECRET="${config.sops.secrets."hyprpanel/openweather_api_key".path}"
    RUNTIME="${config.xdg.configHome}/wayle/runtime.toml"
    $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/wayle"
    if [[ -z "''${DRY_RUN:-}" ]]; then
      ${systemctl} --user start sops-nix.service || true
      for _i in $(seq 1 200); do
        [[ -s "$SECRET" ]] && break
        sleep 0.05
      done
    fi
    if [[ -s "$SECRET" ]]; then
      KEY=$(cat "$SECRET" | tr -d '\n')
      printf '[modules.weather]\napi-key = "%s"\n' "$KEY" > "$RUNTIME"
      $DRY_RUN_CMD chmod 600 "$RUNTIME"
    fi
  '';
}
