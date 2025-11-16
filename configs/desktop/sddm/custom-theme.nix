{ pkgs, lib, inputs, ... }:

let
  # Local theme source directory
  themeSource = ./catppuccin-custom;
  
  # Custom background - copy to nix store for reproducible path
  # This ensures the exact store path is used, making the build reproducible
  customBackground = pkgs.copyPathToStore 
    (inputs.self + "/assets/wallpapers/alucard.jpg");
in

pkgs.stdenv.mkDerivation {
  pname = "catppuccin-sddm-custom";
  version = "1.0.0";
  
  src = pkgs.lib.cleanSource themeSource;
  
  installPhase = ''
    mkdir -p $out/share/sddm/themes/catppuccin-mocha-mauve
    
    # Copy all theme files
    cp -r * $out/share/sddm/themes/catppuccin-mocha-mauve/
    
    # Inject the full nix store path to the wallpaper into theme.conf
    # This ensures reproducibility - the exact store path will be baked in
    substituteInPlace $out/share/sddm/themes/catppuccin-mocha-mauve/theme.conf \
      --replace 'Background="backgrounds/custom-background.jpg"' \
                "Background=\"${customBackground}\""
    
    # Make sure all files are readable
    chmod -R 755 $out/share/sddm/themes/catppuccin-mocha-mauve
  '';
  
  meta = with lib; {
    description = "Custom Catppuccin SDDM theme with repositioned elements";
    license = licenses.mit;
    maintainers = [];
  };
}

