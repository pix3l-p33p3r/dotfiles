{ lib, appimageTools, fetchurl }:

let
  pname = "cursor";
  version = "3.17.21";
  # Official Linux AppImage from Cursor's CDN (same bytes nixpkgs wraps).
  # To bump: GET https://api2.cursor.sh/updates/api/download/stable/linux-x64/cursor
  commit = "8f2a112cb2845a97b75fd932ea5c470579ca4063";

  src = fetchurl {
    url = "https://downloads.cursor.com/production/${commit}/linux/x64/Cursor-${version}-x86_64.AppImage";
    sha256 = "sha256-s1QLqHCfCkUHDsZPtJylKzv8OsnBXg8sW2+ebKmMUbk=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: (appimageTools.defaultFhsEnvArgs.multiPkgs pkgs) ++ (with pkgs; [
    libxshmfence
    tzdata
    python3
    gcc
    gnumake
    libsecret
    libnotify
  ]);

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/cursor.desktop -t $out/share/applications

    if [ -d ${appimageContents}/usr/share/icons ]; then
      mkdir -p $out/share
      cp -r ${appimageContents}/usr/share/icons $out/share/
    else
      install -Dm444 ${appimageContents}/co.anysphere.cursor.png \
        $out/share/icons/hicolor/512x512/apps/co.anysphere.cursor.png
    fi

    mv $out/bin/cursor $out/bin/.cursor-wrapped
    cat > $out/bin/cursor <<'WRAPPER'
#!/bin/sh
exec "$(dirname "$0")/.cursor-wrapped" --no-sandbox --ozone-platform-hint=auto "$@"
WRAPPER
    chmod +x $out/bin/cursor
  '';

  meta = with lib; {
    description = "AI-powered code editor built on VS Code";
    homepage = "https://cursor.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "cursor";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
