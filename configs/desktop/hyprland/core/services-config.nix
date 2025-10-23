{ variables, ... }:
let
  inherit (variables) 
    pidof hyprctl brightnessctl systemctl;
    # hyprlock; # Commented out - configuring manually
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

  # Hyprland-specific services moved to hypridle.nix (now configured manually)
  # Basic hyprlock config is handled in hyprlock.nix via xdg.configFile (now configured manually)
}
