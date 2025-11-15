{ config, pkgs, lib, inputs, ... }:

let
  # Get paths from flake
  avatar = inputs.self + "/assets/avatar/ryuma_pixel-peeper.png";
in
{
  # ───── SDDM Display Manager ─────
  # Using catppuccin-sddm-corners theme from upstream flake
  # Reference: https://github.com/khaneliman/catppuccin-sddm-corners
  
  # Install theme from flake
  environment.systemPackages = [
    inputs.sddm-catppuccin.packages.${pkgs.hostPlatform.system}.catppuccin-sddm-corners
  ];
  
  # Configure SDDM with the theme
  services.displayManager.sddm = {
    enable = true;
    # Use Wayland backend for better performance and security
    wayland.enable = true;
    # Theme name from the flake package
    theme = "catppuccin-sddm-corners";
  };
  
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
      
      # Also copy to user's home directory
      mkdir -p /home/pixel-peeper
      cp ${avatar} /home/pixel-peeper/.face.icon
      chmod 644 /home/pixel-peeper/.face.icon
    '';
  };
  
  # ───── Catppuccin SDDM Configuration ─────
  # Disable the official catppuccin/nix module theme
  # We're using catppuccin-sddm-corners instead
  # catppuccin.sddm = {
  #   enable = false;
  # };
  
  # ───── Ensure Hyprland Session is Available ─────
  # SDDM will automatically detect Hyprland session from programs.hyprland.enable
  # No additional configuration needed - it's handled by the wayland.nix module
}

