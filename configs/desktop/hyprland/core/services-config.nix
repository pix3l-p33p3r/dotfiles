{ config, pkgs, lib, ... }:
{
  # hyprpanel IS the notification daemon (org.freedesktop.Notifications on the session bus).
  # Do NOT run mako alongside it — whichever claims the D-Bus name first wins, and mako
  # would prevent hyprpanel from receiving notifications (breaks history, theming, X buttons).

  # blueman-applet is intentionally NOT enabled. services.blueman.enable is set
  # to false in machines/alucard/bluetooth.nix to drop the ~85 MB tray applet.
  # Pair devices with `bluetui`, `bluetoothctl`, or `blueman-manager` on demand.
  #
  # nm-applet (NetworkManager tray + secret agent) is also disabled below. For
  # new Wi-Fi networks use `nmtui` or `nm-connection-editor` (float window rule
  # already exists in core/settings.nix). Saved networks auto-connect.

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
  # nm-applet disabled (~29 MB). Hyprpanel no longer renders a network widget
  # either — Wi-Fi state surfaces via NetworkManager D-Bus notifications, which
  # hyprpanel forwards as it owns the notification daemon.

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
