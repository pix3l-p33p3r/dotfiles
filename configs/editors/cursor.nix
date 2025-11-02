{ lib, appimageTools, fetchurl, makeWrapper, stdenv }:

let
  pname = "cursor";
  version = "2.0.34";
  
  src = fetchurl {
    url = "https://downloads.cursor.com/production/45fd70f3fe72037444ba35c9e51ce86a1977ac11/linux/x64/Cursor-2.0.34-x86_64.AppImage";
    sha256 = "04y44s1i8if0kccxndfsjqymblb4zwcm6gvyq354fckd3gc4v7f7";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in appimageTools.wrapType2 {
  inherit pname version src;
  
  # Provide additional libraries needed by Cursor/VS Code
  multiPkgs = null; # Use default multiPkgs
  extraPkgs = pkgs: (appimageTools.defaultFhsEnvArgs.multiPkgs pkgs) ++ (with pkgs; [
    # Core libraries
    xorg.libxshmfence
    # For native modules
    python3
    gcc
    gnumake
    # Additional runtime dependencies
    libsecret
    libnotify
  ]);

  extraInstallCommands = ''
    # Install desktop file (already has correct Exec=cursor)
    install -Dm444 ${appimageContents}/cursor.desktop -t $out/share/applications
    
    # Install icons - use the correct icon name from desktop file (co.anysphere.cursor)
    # First try copying the full icons directory structure
    if [ -d ${appimageContents}/usr/share/icons ]; then
      mkdir -p $out/share
      cp -r ${appimageContents}/usr/share/icons $out/share/
    else
      # Fallback: look for PNG files directly in the AppImage root
      for icon in ${appimageContents}/*.png; do
        if [ -f "$icon" ]; then
          install -Dm444 "$icon" $out/share/icons/hicolor/512x512/apps/co.anysphere.cursor.png
          break
        fi
      done
    fi
    
    # Create default Cursor config directory and settings to disable update notifications
    mkdir -p $out/share/cursor-default-config
    cat > $out/share/cursor-default-config/product.json <<EOF
{
  "updateUrl": "",
  "updateMode": "manual"
}
EOF
  '';

  meta = with lib; {
    description = "AI-powered code editor built on VS Code";
    longDescription = ''
      Cursor is a fork of VS Code with AI features built-in.
      It includes features like AI-powered code completion, chat, and more.
    '';
    homepage = "https://cursor.com";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "cursor";
  };
}

