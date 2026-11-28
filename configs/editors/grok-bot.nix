{ lib, appimageTools, fetchurl }:

let
  pname = "grok-bot";
  version = "1.3.0";
  # Cursor/xAI stable build id. To bump: GET
  # https://api2.cursor.sh/updates/api/download/stable/linux-x64/sand
  # then replace version, commit, and sha256.
  commit = "bfb372966cec77c6ec2750957965f2a2268da17d";

  src = fetchurl {
    url = "https://downloads.cursor.com/grokbot/stable/${commit}/linux/x64/Grok_Bot_${version}.AppImage";
    sha256 = "sha256-XXL/SBLjND6wBTk626akzY5Qgjm1giLWkZzgQmeYNeY=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: (appimageTools.defaultFhsEnvArgs.multiPkgs pkgs) ++ (with pkgs; [
    libxshmfence
    tzdata
    libsecret
    libnotify
  ]);

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/grok-bot.desktop -t $out/share/applications
    sed -i 's|^Exec=AppRun.*|Exec=grok-bot %U|' $out/share/applications/grok-bot.desktop

    if [ -d ${appimageContents}/usr/share/icons ]; then
      mkdir -p $out/share
      cp -r ${appimageContents}/usr/share/icons $out/share/
    fi

    # Same NixOS Electron constraint as Cursor: chrome-sandbox cannot
    # PR_SET_NO_NEW_PRIVS under AppArmor + this kernel.
    mv $out/bin/grok-bot $out/bin/.grok-bot-wrapped
    cat > $out/bin/grok-bot <<'WRAPPER'
#!/bin/sh
exec "$(dirname "$0")/.grok-bot-wrapped" --no-sandbox --ozone-platform-hint=auto "$@"
WRAPPER
    chmod +x $out/bin/grok-bot
  '';

  meta = with lib; {
    description = "Grok Bot desktop agent";
    homepage = "https://x.ai/bot";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "grok-bot";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
