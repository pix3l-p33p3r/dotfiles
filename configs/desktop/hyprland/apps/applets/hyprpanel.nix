{ config, pkgs, lib, ... }:

let
  hyprpanelBaseConfig = ./hyprpanel/config/config.json;
  systemctl = lib.getExe' pkgs.systemd "systemctl";
in
{
  # modules.json stays static; config.json merges in the weather API key from sops.
  xdg.configFile = {
    "hyprpanel/modules.json".text = builtins.readFile ./hyprpanel/config/modules.json;
  };

  # After reloadSystemd: the sops-nix user unit in systemd still pointed at the
  # *previous* generation's installer until user units are reloaded.  The sops-nix
  # activation step runs before reloadSystemd, so we start sops-nix again here and
  # wait for the secret path before jq.
  home.activation.hyprpanelConfig = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
    SECRET="${config.sops.secrets."hyprpanel/openweather_api_key".path}"
    $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/hyprpanel"
    if [[ -z "''${DRY_RUN:-}" ]]; then
      ${systemctl} --user start sops-nix.service || true
      for _i in $(seq 1 200); do
        [[ -s "$SECRET" ]] && break
        sleep 0.05
      done
    fi
    if [[ ! -s "$SECRET" ]]; then
      echo "[hyprpanel] SOPS secret still missing at $SECRET after sops-nix.service start." >&2
      echo "[hyprpanel] Copying base config without weather key (re-run home-manager switch after fixing sops)." >&2
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp ${hyprpanelBaseConfig} "${config.xdg.configHome}/hyprpanel/config.json"
    else
      $DRY_RUN_CMD ${lib.getExe pkgs.jq} \
        --rawfile openweather_key "$SECRET" \
        '. + {"menus.clock.weather.key": ($openweather_key | rtrimstr("\n"))}' \
        ${hyprpanelBaseConfig} > "${config.xdg.configHome}/hyprpanel/config.json.tmp"
      $DRY_RUN_CMD mv "${config.xdg.configHome}/hyprpanel/config.json.tmp" "${config.xdg.configHome}/hyprpanel/config.json"
    fi
    $DRY_RUN_CMD chmod 600 "${config.xdg.configHome}/hyprpanel/config.json"
  '';

  systemd.user.services.hyprpanel = {
    Unit = {
      Description = "Hyprland status bar";
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session.target" "sops-nix.service" ];
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
