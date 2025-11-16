{ config, pkgs, lib, inputs, ... }:

let
  # Get paths from flake
  avatar = inputs.self + "/assets/avatar/ryuma_pixel-peeper.png";
in
{
  # ───── SDDM Display Manager ─────
  # Using official catppuccin-sddm theme from nixpkgs
  # Reference: https://github.com/catppuccin/sddm
  
  # Install and configure Catppuccin SDDM theme (Mocha flavor with Mauve accent)
  # Also install required Qt5 dependencies for SDDM themes
  environment.systemPackages = with pkgs; [
    (catppuccin-sddm.override {
      flavor = "mocha";
      accent = "mauve";
      font = "JetBrainsMono Nerd Font";
      fontSize = "9";
      background = inputs.self + "/assets/wallpapers/hellsing-4200x2366-19239.jpg";
      loginBackground = true;
      userIcon = true;  # Enable user icon/avatar display
    })
    # Qt5 dependencies for SDDM themes
    qt5.qtgraphicaleffects  # Qt5 Graphical Effects
    qt5.qtsvg               # Qt5 SVG support
    qt5.qtquickcontrols2    # Qt5 Quick Controls 2
  ];
  
  # Configure SDDM with the theme
  services.displayManager.sddm = {
    enable = true;
    # Use Wayland backend for better performance and security
    wayland.enable = true;
    # Theme name matches the flavor and accent from override
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

