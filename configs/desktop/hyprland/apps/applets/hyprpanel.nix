{ config, pkgs, ... }:

{
  home.file = {
    ".config/hyprpanel/config.json".source = ./hyprpanel/config/config.json;
    ".config/hyprpanel/modules.json".source = ./hyprpanel/config/modules.json;
  };

  systemd.user.services.hyprpanel = {
    Unit = {
      Description = "Hyprland status bar";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.hyprpanel}/bin/hyprpanel";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}

