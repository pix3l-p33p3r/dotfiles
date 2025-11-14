{ config, pkgs, lib, inputs, ... }:

let
  # Get paths from flake
  wallpaper = inputs.self + "/assets/wallpapers/hellsing-4200x2366-19239.jpg";
  avatar = inputs.self + "/assets/avatar/ryuma_pixel-peeper.png";
  
  # Use catppuccin-sddm-corners theme from nixpkgs
  # Reference: https://github.com/khaneliman/catppuccin-sddm-corners
  baseTheme = pkgs.catppuccin-sddm-corners;
  
  # Custom theme with configuration for wallpaper, avatar, time format, and positioning
  customSDDMTheme = pkgs.runCommand "catppuccin-sddm-corners-custom" {
    buildInputs = [ pkgs.python3 ];
  } ''
    # Create directory structure
    mkdir -p $out/share/sddm/themes
    
    # Find and copy the base theme
    THEME_DIR=$(find ${baseTheme}/share/sddm/themes -mindepth 1 -maxdepth 1 -type d | head -1)
    THEME_NAME=$(basename "$THEME_DIR")
    echo "Theme name: $THEME_NAME" >&2
    cp -r "$THEME_DIR" $out/share/sddm/themes/
    chmod -R +w $out
    
    # Store theme name for reference
    echo "$THEME_NAME" > $out/theme-name
    
    # Copy wallpaper to theme backgrounds directory if it doesn't exist
    mkdir -p $out/share/sddm/themes/$THEME_NAME/backgrounds
    cp ${pkgs.copyPathToStore wallpaper} $out/share/sddm/themes/$THEME_NAME/backgrounds/wallpaper.jpg
    
    # Patch theme.conf with our settings
    THEME_CONF="$out/share/sddm/themes/$THEME_NAME/theme.conf"
    if [ -f "$THEME_CONF" ]; then
      # Read current theme.conf and patch it
      sed -i \
        -e "s|\"Background\":.*|\"Background\": \"backgrounds/wallpaper.jpg\"|" \
        -e "s|\"Font\":.*|\"Font\": \"JetBrainsMono Nerd Font\"|" \
        -e "s|\"TimeFormat\":.*|\"TimeFormat\": \"HH:mm:ss\"|" \
        "$THEME_CONF"
    fi
    
    # Patch QML files for:
    # 1. Add seconds to time format (hh:mm -> hh:mm:ss)
    find $out/share/sddm/themes -name "*.qml" -type f -exec sed -i \
      -e 's/"hh:mm"/"hh:mm:ss"/g' \
      -e 's/"HH:mm"/"HH:mm:ss"/g' \
      -e "s/'hh:mm'/'hh:mm:ss'/g" \
      -e "s/'HH:mm'/'HH:mm:ss'/g" \
      -e 's/Qt\.formatTime(\([^,]*\),\s*"hh:mm")/Qt.formatTime(\1, "hh:mm:ss")/g' \
      -e 's/Qt\.formatTime(\([^,]*\),\s*"HH:mm")/Qt.formatTime(\1, "HH:mm:ss")/g' \
      {} +
    
    # 2. Position login panel on left center using Python for reliable QML parsing
    python3 << 'PYTHON_SCRIPT'
import os
import re

# Find all QML files
qml_files = []
for root, dirs, files in os.walk(os.environ['out'] + '/share/sddm/themes'):
    for file in files:
        if file.endswith('.qml'):
            qml_files.append(os.path.join(root, file))

for qml_file in qml_files:
    with open(qml_file, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # Replace center positioning with left positioning
    # Pattern 1: anchors.horizontalCenter: parent.horizontalCenter
    content = re.sub(
        r'(\s+)anchors\.horizontalCenter:\s*parent\.horizontalCenter',
        r'\1anchors.left: parent.left\n\1anchors.leftMargin: 100',
        content
    )
    
    # Pattern 2: anchors.centerIn: parent
    content = re.sub(
        r'(\s+)anchors\.centerIn:\s*parent',
        r'\1anchors.left: parent.left\n\1anchors.leftMargin: 100\n\1anchors.verticalCenter: parent.verticalCenter',
        content
    )
    
    # Pattern 3: x: parent.width * 0.5 - width / 2 (centered calculation)
    content = re.sub(
        r'(\s+)x:\s*parent\.width\s*\*\s*0\.5\s*-\s*width\s*/\s*2',
        r'\1x: 100',
        content
    )
    
    # Pattern 4: x: (parent.width - width) / 2
    content = re.sub(
        r'(\s+)x:\s*\(parent\.width\s*-\s*width\)\s*/\s*2',
        r'\1x: 100',
        content
    )
    
    # Only write if content changed
    if content != original_content:
        with open(qml_file, 'w') as f:
            f.write(content)
        print(f"Patched: {qml_file}")
PYTHON_SCRIPT
  '';
in
{
  # ───── SDDM Display Manager ─────
  # Using catppuccin-sddm-corners theme from nixpkgs
  # Reference: https://github.com/khaneliman/catppuccin-sddm-corners
  # Auto-launches Hyprland after login
  
  services.displayManager.sddm = {
    enable = true;
    
    # Use Wayland backend for better performance and security
    wayland.enable = true;
    
    # Use KDE SDDM package (includes Qt5 dependencies automatically)
    # Qt5, Qt Graphical Effects, Qt SVG, and Qt Quick Controls 2 are included
    package = pkgs.kdePackages.sddm;
    
    # Use our custom theme based on catppuccin-sddm-corners
    # Theme name is "catppuccin" (from the package structure)
    theme = "catppuccin";
    
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
        Current = "catppuccin";
      };
    };
  };
  
  # ───── Catppuccin SDDM Configuration ─────
  # Disable the official catppuccin/nix module theme
  # We're using catppuccin-sddm-corners instead
  catppuccin.sddm = {
    enable = false;
  };
  
  # ───── Install Custom SDDM Theme ─────
  # Our custom theme with wallpaper, avatar, seconds, and left-aligned login panel
  environment.systemPackages = [ customSDDMTheme ];
  
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

