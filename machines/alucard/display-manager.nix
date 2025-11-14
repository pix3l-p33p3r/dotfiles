{ config, pkgs, lib, inputs, ... }:

let
  # Get paths from flake
  wallpaper = inputs.self + "/assets/wallpapers/hellsing-4200x2366-19239.jpg";
  avatar = inputs.self + "/assets/avatar/ryuma_pixel-peeper.png";
in
{
  # ───── SDDM Display Manager ─────
  # Using catppuccin/nix module for clean configuration
  # Reference: https://nix.catppuccin.com/options/25.05/nixos/catppuccin.sddm/
  # Auto-launches Hyprland after login
  
  services.displayManager.sddm = {
    enable = true;
    
    # Use Wayland backend for better performance and security
    wayland.enable = true;
    
    # Use KDE SDDM package (required for proper theme support)
    package = pkgs.kdePackages.sddm;
    
    # Settings for SDDM
    settings = {
      General = {
        # Show user list for convenience (users can click or type username)
        HideUsers = "";
        Numlock = "on";
        InputMethod = "";
        EnableHiDPI = true;
      };
    };
  };
  
  # ───── Catppuccin SDDM Configuration ─────
  # Using the official catppuccin/nix module
  # Options: https://nix.catppuccin.com/options/25.05/nixos/catppuccin.sddm/
  catppuccin.sddm = {
    enable = true;
    flavor = "mocha";
    accent = "lavender";  # Matches your system accent
    font = "JetBrainsMono Nerd Font";
    fontSize = "11";
    background = wallpaper;  # Your custom wallpaper
    loginBackground = true;  # Show background around login panel
    userIcon = true;  # Enable user icon display
    clockEnabled = true;  # Enable clock (will be patched to show seconds)
  };
  
  # ───── Override Theme Package to Add Seconds ─────
  # The catppuccin module creates a theme package, we override it to patch QML files for seconds
  # This is done at build time, not runtime, so it's more reliable
  nixpkgs.overlays = [
    (final: prev: {
      # Override the catppuccin-sddm package to add seconds
      catppuccin-sddm = prev.catppuccin-sddm.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          # Patch QML files to add seconds to time format
          find $out/share/sddm/themes -name "*.qml" -type f -exec sed -i \
            -e 's/"hh:mm"/"hh:mm:ss"/g' \
            -e 's/"HH:mm"/"HH:mm:ss"/g' \
            -e "s/'hh:mm'/'hh:mm:ss'/g" \
            -e "s/'HH:mm'/'HH:mm:ss'/g" \
            {} +
        '';
      });
    })
  ];
  
  # ───── Copy Avatar for SDDM User Icon ─────
  # SDDM looks for user icons in /var/lib/AccountsService/icons/
  # Also supports ~/.face.icon or FacesDir/username.face.icon
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
      
      # Also copy to user's home directory for catppuccin.sddm.userIcon
      mkdir -p /home/pixel-peeper
      cp ${avatar} /home/pixel-peeper/.face.icon
      chmod 644 /home/pixel-peeper/.face.icon
    '';
  };
  
  # ───── Ensure Hyprland Session is Available ─────
  # SDDM will automatically detect Hyprland session from programs.hyprland.enable
  # No additional configuration needed - it's handled by the wayland.nix module
}

