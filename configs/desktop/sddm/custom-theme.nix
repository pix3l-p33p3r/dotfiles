{ pkgs, lib, inputs, ... }:

let
  # Local theme source directory
  themeSource = ./catppuccin-custom;
  
  # Custom background
  customBackground = inputs.self + "/assets/wallpapers/hellsing-4200x2366-19239.jpg";
in

pkgs.stdenv.mkDerivation {
  pname = "catppuccin-sddm-custom";
  version = "1.0.0";
  
  src = pkgs.lib.cleanSource themeSource;
  
  installPhase = ''
    mkdir -p $out/share/sddm/themes/catppuccin-mocha-mauve
    
    # Copy all theme files
    cp -r * $out/share/sddm/themes/catppuccin-mocha-mauve/
    
    # Copy custom background to backgrounds directory
    mkdir -p $out/share/sddm/themes/catppuccin-mocha-mauve/backgrounds
    cp ${customBackground} $out/share/sddm/themes/catppuccin-mocha-mauve/backgrounds/custom-background.jpg
    
    # Make sure all files are readable
    chmod -R 755 $out/share/sddm/themes/catppuccin-mocha-mauve
  '';
  
  meta = with lib; {
    description = "Custom Catppuccin SDDM theme with repositioned elements";
    license = licenses.mit;
    maintainers = [];
  };
}

