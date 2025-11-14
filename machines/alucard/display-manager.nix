{ config, pkgs, lib, ... }:

let
  # Catppuccin Mocha color palette
  colors = {
    base = "#1e1e2e";
    mantle = "#181825";
    crust = "#11111b";
    surface0 = "#313244";
    surface1 = "#45475a";
    surface2 = "#585b70";
    text = "#cdd6f4";
    subtext1 = "#bac2de";
    subtext0 = "#a6adc8";
    lavender = "#b4befe";
    blue = "#89b4fa";
    red = "#f38ba8";
  };
  
  # Create a minimal Catppuccin Mocha themed SDDM theme
  # Using a simple approach that works with SDDM's theme system
  catppuccinTheme = pkgs.runCommand "sddm-catppuccin-mocha" {} ''
    mkdir -p $out/share/sddm/themes/catppuccin-mocha
    
    cat > $out/share/sddm/themes/catppuccin-mocha/theme.conf << EOF
    [General]
    type=image
    color=${colors.base}
    font=JetBrainsMono Nerd Font
    fontSize=11
    
    [Background]
    color=${colors.base}
    mode=scale
    type=image
    
    [Users]
    iconTheme=
    avatarFont=JetBrainsMono Nerd Font
    avatarFontSize=56
    avatarBackgroundColor=${colors.mantle}
    avatarRadius=50
    
    [UserList]
    avatarBackgroundColor=${colors.mantle}
    avatarRadius=50
    
    [Login]
    font=JetBrainsMono Nerd Font
    fontSize=11
    textColor=${colors.text}
    passwordFont=JetBrainsMono Nerd Font
    passwordFontSize=11
    passwordColor=${colors.text}
    passwordBackgroundColor=${colors.surface0}
    passwordBorderColor=${colors.surface1}
    passwordBorderRadius=8
    passwordMarginTop=10
    passwordPadding=10
    
    [Time]
    font=JetBrainsMono Nerd Font
    fontSize=48
    color=${colors.text}
    format="hh:mm:ss"
    
    [Date]
    font=JetBrainsMono Nerd Font
    fontSize=18
    color=${colors.subtext1}
    format="dddd, MMMM d, yyyy"
    
    [Welcome]
    font=JetBrainsMono Nerd Font
    fontSize=14
    color=${colors.lavender}
    
    [ErrorMessage]
    font=JetBrainsMono Nerd Font
    fontSize=11
    color=${colors.red}
    backgroundColor=${colors.surface0}
    padding=10
    borderRadius=8
    
    [Button]
    font=JetBrainsMono Nerd Font
    fontSize=11
    textColor=${colors.text}
    textColorHover=${colors.base}
    backgroundColor=${colors.surface0}
    backgroundColorHover=${colors.lavender}
    backgroundColorPressed=${colors.blue}
    borderRadius=8
    padding=10
    EOF
  '';
in
{
  # ───── SDDM Display Manager ─────
  # Lightweight, fast display manager with Catppuccin Mocha theme
  # Auto-launches Hyprland after login
  
  services.displayManager.sddm = {
    enable = true;
    
    # Use Wayland backend for better performance and security
    wayland.enable = true;
    
    # Use Catppuccin Mocha theme
    # Note: If the custom theme doesn't work, SDDM will fall back to default
    # You can change this to "maldives" (minimal, fast) if needed
    theme = "catppuccin-mocha";
    
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
        Current = "catppuccin-mocha";
      };
    };
  };
  
  # ───── Install Catppuccin Mocha Theme ─────
  environment.systemPackages = [ catppuccinTheme ];
  
  # ───── SDDM Theme Directory ─────
  # Ensure theme directory exists
  systemd.tmpfiles.rules = [
    "d /run/current-system/sw/share/sddm/themes 0755 root root -"
  ];
  
  # ───── Ensure Hyprland Session is Available ─────
  # SDDM will automatically detect Hyprland session from programs.hyprland.enable
  # No additional configuration needed - it's handled by the wayland.nix module
}

