{ pkgs, ... }:
{
  home.packages = [ pkgs.hypridle ];

  xdg.configFile."hypridle/hypridle.conf".text = ''
    general {
      lock_cmd = pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock
      before_sleep_cmd = loginctl lock-session
      after_sleep_cmd = hyprctl dispatch dpms on
    }

    listener {
      timeout = 300                                  
      on-timeout = brightnessctl -s set 10         
      on-resume = brightnessctl -r                 
    }

    listener {
      timeout = 330
      on-timeout = loginctl lock-session
    }

    listener {
      timeout = 350
      on-timeout = hyprctl dispatch dpms off
      on-resume = hyprctl dispatch dpms on
    }
  '';

  # Systemd user service for hypridle
  systemd.user.services.hypridle = {
    Unit = {
      Description = "Hyprland idle daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.hypridle}/bin/hypridle";
      Restart = "always";
      RestartSec = 5;
    };
    
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
