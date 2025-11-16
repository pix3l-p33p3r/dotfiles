{ config, pkgs, lib, inputs, ... }:

let
  # Get paths from flake
  avatar = inputs.self + "/assets/avatar/ryuma_pixel-peeper.png";
  
  # Custom SDDM theme built from local files
  # Theme files are in configs/desktop/sddm/catppuccin/
  # You can customize theme.conf, Main.qml, and component QML files there
  customSddmTheme = (import ../../configs/desktop/sddm/default.nix {
    inherit pkgs lib inputs;
  });
in
{
  # ───── SDDM Display Manager ─────
  # Using custom catppuccin-sddm-corners theme from local files
  # Reference: https://github.com/khaneliman/catppuccin-sddm-corners
  # Theme files are in: configs/desktop/sddm/catppuccin/
  # Customize theme.conf, Main.qml, or component QML files as needed
  
  # Install custom SDDM theme (built from local files)
  # Also install Qt6 compatibility package for Qt5Compat.GraphicalEffects
  environment.systemPackages = with pkgs; [
    customSddmTheme
    qt6.qt5compat  # Required for Qt5Compat.GraphicalEffects in Qt6-based SDDM
  ];
  
  # Configure SDDM with the custom theme
  services.displayManager.sddm = {
    enable = true;
    # Use Wayland backend for better performance and security
    wayland.enable = true;
    # Theme name from our custom build
    theme = "catppuccin-sddm-corners";
    package = pkgs.kdePackages.sddm;
  };
  

  systemd.services.sddm-avatar = {
    description = "Copy user avatar for SDDM";
    wantedBy = [ "multi-user.target" ];
    before = [ "display-manager.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      # Copy to AccountsService location
      mkdir -p /var/lib/AccountsService/icons
      cp ${avatar} /var/lib/AccountsService/icons/pixel-peeper
      chmod 644 /var/lib/AccountsService/icons/pixel-peeper
      
      # Also copy to user's home directory
      mkdir -p /home/pixel-peeper
      cp ${avatar} /home/pixel-peeper/.face.icon
      chmod 644 /home/pixel-peeper/.face.icon
    '';
  };
}

