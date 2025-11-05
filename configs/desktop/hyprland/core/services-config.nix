{ variables, ... }:
let
  inherit (variables) 
    pidof hyprctl brightnessctl systemctl ;
in
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

  services.gnome-keyring = {
    enable = true;
    components = [
      "secrets"
      "ssh"
    ];
  };

  services.poweralertd.enable = true;
  services.network-manager-applet.enable = true;

  # Polkit agent (required for GUI auth prompts e.g., udisks mounts in Thunar)
  services.lxqt-policykit.enable = true;

  # MPD (Music Player Daemon) as a user service for rmpc/kew
  services.mpd = {
    enable = true;
    musicDirectory = "/home/pixel-peeper/Music";
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
