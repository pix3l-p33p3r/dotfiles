{ config, pkgs, lib, inputs, ... }:

let
  # Get paths from flake
  avatar = inputs.self + "/assets/avatar/ryuma_pixel-peeper.png";
in
{
  # ───── SDDM Display Manager ─────
  # Using custom catppuccin-sddm theme with repositioned elements
  # Layout:
  # - Clock (H:M:S format) in top-left
  # - Avatar in top-left (below clock)
  # - Login form (username/password/login) in center-left
  # - Session panel + Power/Reboot/Sleep buttons grouped in bottom-left
  
  # Custom SDDM theme built from local files
  customSddmTheme = (import ../../configs/desktop/sddm/custom-theme.nix {
    inherit pkgs lib inputs;
  });
  
  # Install custom SDDM theme and required Qt5 dependencies
  environment.systemPackages = with pkgs; [
    customSddmTheme
    # Qt5 dependencies for SDDM themes
    qt5.qtgraphicaleffects  # Qt5 Graphical Effects
    qt5.qtsvg               # Qt5 SVG support
    qt5.qtquickcontrols2    # Qt5 Quick Controls 2
  ];
  
  # Configure SDDM with the custom theme
  services.displayManager.sddm = {
    enable = true;
    # Use Wayland backend for better performance and security
    wayland.enable = true;
    # Theme name from custom build
    theme = "catppuccin-mocha-mauve";
    package = pkgs.kdePackages.sddm;
  };
  

  # Copy avatar to all locations SDDM might look for it
  systemd.services.sddm-avatar = {
    description = "Copy user avatar for SDDM";
    wantedBy = [ "multi-user.target" ];
    before = [ "display-manager.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      # Copy to AccountsService location (used by SDDM)
      mkdir -p /var/lib/AccountsService/icons
      cp ${avatar} /var/lib/AccountsService/icons/pixel-peeper
      chmod 644 /var/lib/AccountsService/icons/pixel-peeper
      
      # Also copy to AccountsService FacesDir location
      mkdir -p /var/lib/AccountsService/faces
      cp ${avatar} /var/lib/AccountsService/faces/pixel-peeper.face.icon
      chmod 644 /var/lib/AccountsService/faces/pixel-peeper.face.icon
      
      # Copy to user's home directory (standard location)
      mkdir -p /home/pixel-peeper
      cp ${avatar} /home/pixel-peeper/.face.icon
      chmod 644 /home/pixel-peeper/.face.icon
      
      # Also create .face symlink (alternative name some themes use)
      ln -sf /home/pixel-peeper/.face.icon /home/pixel-peeper/.face
      chmod 644 /home/pixel-peeper/.face
    '';
  };
}

