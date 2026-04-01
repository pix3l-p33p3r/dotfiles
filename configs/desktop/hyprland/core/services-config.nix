{ config, pkgs, lib, ... }:
{
  # System services
  services.blueman-applet.enable = true;

  services.cliphist = {
    enable = true;
    allowImages = true;
    systemdTargets = [ "hyprland-session.target" ];
    extraOptions = [
      "-max-items"
      "100"
    ];
  };

  # gnome-keyring disabled: KeePassXC owns both the SSH agent and the
  # Freedesktop Secret Service API. Keeping gnome-keyring running (even with
  # no components) triggers a warning in KeePassXC and risks SSH_AUTH_SOCK hijack.
  services.gnome-keyring.enable = false;

  services.poweralertd.enable = true;
  # Skip startup broadcast: without a notification daemon ready, poweralertd can exit
  # with "could not send state update notification: No route to host" and restart-loop.
  systemd.user.services.poweralertd.Service.ExecStart =
    lib.mkForce "${pkgs.poweralertd}/bin/poweralertd -s";
  services.network-manager-applet.enable = true;

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
