{ lib, appimageTools, fetchurl, makeWrapper, stdenv }:

let
  pname = "cursor";
  version = "3.1.15";

  src = fetchurl {
    url = "https://github.com/udit-001/cursor-linux-release/releases/download/v${version}/Cursor-${version}-x86_64.AppImage";
    sha256 = "0n8si64if4vnj577w8vrq9spx89dl85qk097j062yifaiwb8x44h";
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
    libxshmfence
    # Timezone data required by Chromium/Electron
    tzdata
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

    # Disable Electron's sandbox to prevent PR_SET_NO_NEW_PRIVS, which blocks
    # sudo in integrated terminals and triggers "Terminal sandbox could not
    # start" on NixOS with AppArmor + kernel 6.2+.
    mv $out/bin/cursor $out/bin/.cursor-wrapped
    cat > $out/bin/cursor <<'WRAPPER'
#!/bin/sh
exec "$(dirname "$0")/.cursor-wrapped" --no-sandbox "$@"
WRAPPER
    chmod +x $out/bin/cursor
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

