{ config, pkgs, lib, ... }:
{
  # hyprpanel IS the notification daemon (org.freedesktop.Notifications on the session bus).
  # Do NOT run mako alongside it — whichever claims the D-Bus name first wins, and mako
  # would prevent hyprpanel from receiving notifications (breaks history, theming, X buttons).

  # blueman-applet is started by the NixOS services.blueman module (bluetooth.nix)
  # via D-Bus activation. Enabling it here too causes a duplicate ExecStart= conflict.

  services.cliphist = {
    enable = true;
    allowImages = true;
    systemdTargets = [ "hyprland-session.target" ];
    extraOptions = [
      "-max-items"
      "100"
    ];
  };

  # Enable gnome-keyring
  services.gnome-keyring.enable = true;

  services.poweralertd.enable = true;
  # -s: skip startup broadcast (avoids crash before the notification daemon is ready).
  # Wait for hyprpanel which owns org.freedesktop.Notifications on this session.
  systemd.user.services.poweralertd = {
    Unit.After = [ "hyprpanel.service" ];
    Service.ExecStart = lib.mkForce "${pkgs.poweralertd}/bin/poweralertd -s";
  };
  services.network-manager-applet.enable = true;
  # Hyprland often reaches hyprland-session.target before graphical-session.target; bind the
  # NM secret agent to both so "no agents were available" does not happen on Wi-Fi connect.
  systemd.user.services.network-manager-applet = {
    Unit = {
      Description = "Network Manager applet";
      Requires = [ "tray.target" ];
      PartOf = lib.mkForce [ "graphical-session.target" "hyprland-session.target" ];
      After = lib.mkForce [
        "graphical-session.target"
        "tray.target"
        "hyprland-session.target"
      ];
    };
    Install.WantedBy = lib.mkForce [ "graphical-session.target" "hyprland-session.target" ];
  };

  # Polkit agent (required for GUI auth prompts e.g., udisks mounts in Thunar)
  services.polkit-gnome.enable = true;

  # MPD (Music Player Daemon) as a user service for rmpc/kew
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    network = {
      listenAddress = "127.0.0.1";
      port = 6600;
    };
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire Output"
      }
      restore_paused "yes"
      auto_update "yes"
    '';
  };

  # Expose MPD to MPRIS so Hyprpanel can read it via playerctl
  services.mpdris2.enable = true;

}
