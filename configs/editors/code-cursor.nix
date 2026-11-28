{ lib, appimageTools, fetchurl }:

let
  pname = "cursor";
  version = "3.32.10";
  # Cursor stable. To bump: GET
  # https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable
  # then replace version, commit, and hash.
  commit = "0d3b96e46ce65af82ed74bc6f14883b33e1a0597";

  src = fetchurl {
    url = "https://downloads.cursor.com/production/${commit}/linux/x64/Cursor-${version}-x86_64.AppImage";
    hash = "sha256-SY0wanivqgcUexiOhs4RqULQmIRxyRTyfMzpKNj7iIo=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: (appimageTools.defaultFhsEnvArgs.multiPkgs pkgs) ++ (with pkgs; [
    libxshmfence
    libsecret
    libnotify
  ]);

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/cursor.desktop -t $out/share/applications || true
    if [ -f $out/share/applications/cursor.desktop ]; then
      sed -i 's|^Exec=.*|Exec=cursor %F|' $out/share/applications/cursor.desktop
    fi

    if [ -d ${appimageContents}/usr/share/icons ]; then
      mkdir -p $out/share
      cp -r ${appimageContents}/usr/share/icons $out/share/
    elif [ -f ${appimageContents}/cursor.png ]; then
      install -Dm644 ${appimageContents}/cursor.png \
        $out/share/pixmaps/cursor.png
    fi

    # Cluster Electron: no setuid chrome-sandbox under AppArmor + this kernel.
    mv $out/bin/cursor $out/bin/.cursor-wrapped
    cat > $out/bin/cursor <<'WRAPPER'
#!/bin/sh
exec "$(dirname "$0")/.cursor-wrapped" --no-sandbox "$@"
WRAPPER
    chmod +x $out/bin/cursor
  '';

  meta = with lib; {
    description = "Cursor AI code editor";
    homepage = "https://cursor.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "cursor";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
