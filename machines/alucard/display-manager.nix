{ config, pkgs, lib, inputs, ... }:

let
  # Get paths from flake
  wallpaper = inputs.self + "/assets/wallpapers/hellsing-4200x2366-19239.jpg";
  avatar = inputs.self + "/assets/avatar/ryuma_pixel-peeper.png";
  
  # Official Catppuccin SDDM theme from nixpkgs
  # Customized for Mocha flavor with Lavender accent
  # Reference: https://github.com/catppuccin/sddm
  catppuccinSDDM = pkgs.catppuccin-sddm.override {
    flavor = "mocha";
    accent = "lavender";  # Matches your system accent
    font = "JetBrainsMono Nerd Font";
    fontSize = "11";
    background = wallpaper;
    loginBackground = true;  # Show background around login panel
  };
  
  # Copy avatar to a location accessible by SDDM
  # SDDM needs the avatar in a system-accessible location
  avatarPackage = pkgs.runCommand "sddm-avatar" {} ''
    mkdir -p $out/share/sddm/faces
    cp ${avatar} $out/share/sddm/faces/pixel-peeper.face.icon
  '';
in
{
  # ───── SDDM Display Manager ─────
  # Lightweight, fast display manager with official Catppuccin Mocha theme
  # Auto-launches Hyprland after login
  # Theme: https://github.com/catppuccin/sddm
  
  services.displayManager.sddm = {
    enable = true;
    
    # Use Wayland backend for better performance and security
    wayland.enable = true;
    
    # Use official Catppuccin Mocha theme with Lavender accent
    theme = "catppuccin-mocha-lavender";
    
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
      
      Theme = {
        Current = "catppuccin-mocha-lavender";
      };
    };
  };
  
  # ───── Install Official Catppuccin SDDM Theme ─────
  # This installs the theme package with our customizations
  environment.systemPackages = [ catppuccinSDDM avatarPackage ];
  
  # ───── Copy Avatar for SDDM User Icon ─────
  # SDDM looks for user icons in /var/lib/AccountsService/icons/
  # We'll create a systemd service to copy the avatar on boot
  systemd.services.sddm-avatar = {
    description = "Copy user avatar for SDDM";
    wantedBy = [ "multi-user.target" ];
    before = [ "display-manager.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /var/lib/AccountsService/icons
      cp ${avatar} /var/lib/AccountsService/icons/pixel-peeper
      chmod 644 /var/lib/AccountsService/icons/pixel-peeper
    '';
  };
  
  # ───── Ensure Hyprland Session is Available ─────
  # SDDM will automatically detect Hyprland session from programs.hyprland.enable
  # No additional configuration needed - it's handled by the wayland.nix module
}

