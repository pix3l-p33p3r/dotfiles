{ config, pkgs, lib, ... }:

let
  hyprpanelBaseConfig = ./hyprpanel/config/config.json;
in
{
  # modules.json stays static; config.json merges in the weather API key from sops.
  xdg.configFile = {
    "hyprpanel/modules.json".text = builtins.readFile ./hyprpanel/config/modules.json;
  };

  home.activation.hyprpanelConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/hyprpanel"
    $DRY_RUN_CMD ${lib.getExe pkgs.jq} \
      --rawfile openweather_key "${config.sops.secrets."hyprpanel/openweather_api_key".path}" \
      '. + {"menus.clock.weather.key": ($openweather_key | rtrimstr("\n"))}' \
      ${hyprpanelBaseConfig} > "${config.xdg.configHome}/hyprpanel/config.json.tmp"
    $DRY_RUN_CMD mv "${config.xdg.configHome}/hyprpanel/config.json.tmp" "${config.xdg.configHome}/hyprpanel/config.json"
    $DRY_RUN_CMD chmod 600 "${config.xdg.configHome}/hyprpanel/config.json"
  '';

  systemd.user.services.hyprpanel = {
    Unit = {
      Description = "Hyprland status bar";
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
      ExecStart = "${pkgs.hyprpanel}/bin/hyprpanel";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };
}
