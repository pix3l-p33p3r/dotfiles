{ pkgs, lib, inputs, ... }:

let
  # Local theme source directory - reference the catppuccin folder
  themeSource = ./catppuccin;
  
  # Custom background (can be overridden)
  customBackground = inputs.self + "/assets/wallpapers/alucard.jpg";
in

pkgs.stdenv.mkDerivation {
  pname = "catppuccin-sddm-custom";
  version = "1.0.0";
  
  src = pkgs.lib.cleanSource themeSource;
  
  # Ensure theme files are copied correctly
  installPhase = ''
    mkdir -p $out/share/sddm/themes/catppuccin-sddm-corners
    
    # Copy all theme files
    cp -r * $out/share/sddm/themes/catppuccin-sddm-corners/
    
    # Replace background with custom one if desired
    # Optionally copy custom background to backgrounds/ directory
    mkdir -p $out/share/sddm/themes/catppuccin-sddm-corners/backgrounds
    cp ${customBackground} $out/share/sddm/themes/catppuccin-sddm-corners/backgrounds/custom-background.jpg
    
    # Make sure theme.conf is executable if needed
    chmod -R 755 $out/share/sddm/themes/catppuccin-sddm-corners
  '';
  
  meta = with lib; {
    description = "Custom Catppuccin SDDM theme (corners variant) - locally customizable";
    license = licenses.gpl3Only;
    maintainers = [];
  };
}

