{ config, pkgs, lib, inputs, ... }:

let
  # Get paths from flake
  wallpaper = inputs.self + "/assets/wallpapers/hellsing-4200x2366-19239.jpg";
  avatar = inputs.self + "/assets/avatar/ryuma_pixel-peeper.png";
  
  # Use catppuccin-sddm-corners theme from nixpkgs
  # Reference: https://github.com/khaneliman/catppuccin-sddm-corners
  baseTheme = pkgs.catppuccin-sddm-corners;
  
  # Custom theme with wallpaper and user icon configuration
  customSDDMTheme = pkgs.runCommand "catppuccin-sddm-corners-custom" {} ''
    # Create directory structure
    mkdir -p $out/share/sddm/themes
    
    # Find and copy the base theme
    THEME_DIR=$(find ${baseTheme}/share/sddm/themes -mindepth 1 -maxdepth 1 -type d | head -1)
    THEME_NAME=$(basename "$THEME_DIR")
    echo "Theme name: $THEME_NAME" >&2
    cp -r "$THEME_DIR" $out/share/sddm/themes/
    chmod -R +w $out
    
    # Copy wallpaper to theme backgrounds directory
    mkdir -p $out/share/sddm/themes/$THEME_NAME/backgrounds
    cp ${pkgs.copyPathToStore wallpaper} $out/share/sddm/themes/$THEME_NAME/backgrounds/wallpaper.jpg
    
    # Patch theme.conf to use the wallpaper
    THEME_CONF="$out/share/sddm/themes/$THEME_NAME/theme.conf"
    if [ -f "$THEME_CONF" ]; then
      sed -i 's|"Background":.*|"Background": "backgrounds/wallpaper.jpg"|' "$THEME_CONF"
    fi
  '';
in
{
  # ───── SDDM Display Manager ─────
  # Using catppuccin-sddm-corners theme from nixpkgs with custom wallpaper
  # Reference: https://github.com/khaneliman/catppuccin-sddm-corners
  # Installation guide: https://github.com/khaneliman/catppuccin-sddm-corners#nixos
  
  # Install custom theme with wallpaper
  environment.systemPackages = [ customSDDMTheme ];
  
  # Configure SDDM with the theme
  services.displayManager.sddm = {
    enable = true;
    # Use Wayland backend for better performance and security
    wayland.enable = true;
    # Theme name from the package (catppuccin-sddm-corners)
    theme = "catppuccin-sddm-corners";
    # Qt6 dependencies - SDDM has been updated to Qt6 in recent nixpkgs
    # The theme should work with Qt6 equivalents
    extraPackages = with pkgs.kdePackages; [
      qtsvg
      qtdeclarative
    ];
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

