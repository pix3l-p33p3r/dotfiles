{ config, pkgs, ... }:

{
  # Use XDG config path (not home.file under .config) to avoid symlink edge cases
  # that produced ELOOP for hyprpanel reading config.json.
  xdg.configFile = {
    "hyprpanel/config.json".source = ./hyprpanel/config/config.json;
    "hyprpanel/modules.json".source = ./hyprpanel/config/modules.json;
  };

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
