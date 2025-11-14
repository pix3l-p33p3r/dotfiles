{ config, pkgs, lib, inputs, ... }:

let
  # Get paths from flake
  wallpaper = inputs.self + "/assets/wallpapers/hellsing-4200x2366-19239.jpg";
  avatar = inputs.self + "/assets/avatar/ryuma_pixel-peeper.png";
  
  # Catppuccin SDDM Corners theme from nixpkgs
  # Beautiful layout with better avatar placement
  # Reference: https://github.com/khaneliman/catppuccin-sddm-corners
  catppuccinSDDMCorners = pkgs.catppuccin-sddm-corners;
  
  # Custom theme configuration with user wallpaper and avatar
  # The theme supports power, session, and user popups (reboot, poweroff, sleep/hibernate)
  customTheme = pkgs.runCommand "catppuccin-sddm-corners-custom" {} ''
    # Create theme directory structure
    mkdir -p $out/share/sddm/themes/catppuccin-sddm-corners-custom
    
    # Copy the original theme files
    # The package may use "catppuccin" or "catppuccin-sddm-corners" as theme name
    if [ -d ${catppuccinSDDMCorners}/share/sddm/themes/catppuccin ]; then
      cp -r ${catppuccinSDDMCorners}/share/sddm/themes/catppuccin/* $out/share/sddm/themes/catppuccin-sddm-corners-custom/
    elif [ -d ${catppuccinSDDMCorners}/share/sddm/themes/catppuccin-sddm-corners ]; then
      cp -r ${catppuccinSDDMCorners}/share/sddm/themes/catppuccin-sddm-corners/* $out/share/sddm/themes/catppuccin-sddm-corners-custom/
    else
      # Try to find the theme directory
      THEME_DIR=$(find ${catppuccinSDDMCorners}/share/sddm/themes -mindepth 1 -maxdepth 1 -type d | head -1)
      cp -r $THEME_DIR/* $out/share/sddm/themes/catppuccin-sddm-corners-custom/
    fi
    chmod -R +w $out/share/sddm/themes/catppuccin-sddm-corners-custom
    
    # Copy user wallpaper to theme backgrounds directory
    mkdir -p $out/share/sddm/themes/catppuccin-sddm-corners-custom/backgrounds
    cp ${wallpaper} $out/share/sddm/themes/catppuccin-sddm-corners-custom/backgrounds/wallpaper.jpg
    
    # Copy user avatar to theme directory
    mkdir -p $out/share/sddm/themes/catppuccin-sddm-corners-custom/faces
    cp ${avatar} $out/share/sddm/themes/catppuccin-sddm-corners-custom/faces/pixel-peeper.face.icon
    
    # Create custom theme.conf with Catppuccin Mocha colors and user settings
    cat > $out/share/sddm/themes/catppuccin-sddm-corners-custom/theme.conf <<EOF
    [General]
    Background="backgrounds/wallpaper.jpg"
    Font="JetBrainsMono Nerd Font"
    Padding="20"
    CornerRadius="15"
    GeneralFontSize="11"
    LoginScale="0.9"
    
    # User picture settings
    UserPictureBorderWidth="3"
    UserPictureBorderColor="#b4befe"
    UserPictureColor="#313244"
    
    # Text field settings (Catppuccin Mocha colors)
    TextFieldColor="#313244"
    TextFieldTextColor="#cdd6f4"
    TextFieldHighlightColor="#b4befe"
    TextFieldHighlightWidth="2"
    UserFieldBgText="Username"
    PasswordFieldBgText="Password"
    
    # Login button (Lavender accent)
    LoginButtonTextColor="#1e1e2e"
    LoginButtonBgColor="#b4befe"
    LoginButtonText="Login"
    
    # Popup settings (power, session, user panels)
    PopupBgColor="#313244"
    PopupHighlightColor="#b4befe"
    PopupHighlightedTextColor="#1e1e2e"
    
    # Session button
    SessionButtonColor="#45475a"
    SessionIconColor="#b4befe"
    
    # Power button (supports reboot, poweroff, sleep, hibernate)
    PowerButtonColor="#45475a"
    PowerIconColor="#b4befe"
    
    # Date display
    DateColor="#bac2de"
    DateSize="14"
    DateIsBold="false"
    DateOpacity="0.9"
    DateFormat="dddd, MMMM d, yyyy"
    
    # Time display
    TimeColor="#cdd6f4"
    TimeSize="48"
    TimeIsBold="true"
    TimeOpacity="1.0"
    TimeFormat="HH:mm:ss"
    EOF
  '';
in
{
  # ───── SDDM Display Manager ─────
  # Using Catppuccin SDDM Corners theme with beautiful layout
  # Features: Power buttons (reboot, poweroff, sleep, hibernate), session selection, user switching
  # Theme: https://github.com/khaneliman/catppuccin-sddm-corners
  # Auto-launches Hyprland after login
  
  services.displayManager.sddm = {
    enable = true;
    
    # Use Wayland backend for better performance and security
    wayland.enable = true;
    
    # Use Catppuccin SDDM Corners theme with custom configuration
    theme = "catppuccin-sddm-corners-custom";
    
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
        Current = "catppuccin-sddm-corners-custom";
      };
    };
  };
  
  # ───── Install Custom Catppuccin SDDM Corners Theme ─────
  # This installs the theme with user wallpaper and avatar
  environment.systemPackages = [ customTheme ];
  
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
  
  # ───── Power Management for SDDM ─────
  # The catppuccin-sddm-corners theme includes power buttons that use systemd-logind
  # Power management is already configured in power.nix:
  # - Reboot: systemctl reboot
  # - Poweroff: systemctl poweroff
  # - Sleep: systemctl suspend (configured in power.nix)
  # - Hibernate: systemctl hibernate (configured in power.nix)
  # No additional configuration needed - the theme's power buttons will work automatically
}

