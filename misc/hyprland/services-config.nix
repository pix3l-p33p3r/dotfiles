{ variables, ... }:
let
  inherit (variables) 
    pidof hyprlock hyprctl brightnessctl systemctl;
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

  # Hyprland-specific services moved to hypridle.nix

  # Basic hyprlock config is handled in hyprlock.nix via xdg.configFile
}
