{ config, pkgs, ... }:

{
  # Real file contents (not store symlinks) so a bad manual symlink cannot cause ELOOP on config.json.
  xdg.configFile = {
    "hyprpanel/config.json".text = builtins.readFile ./hyprpanel/config/config.json;
    "hyprpanel/modules.json".text = builtins.readFile ./hyprpanel/config/modules.json;
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
