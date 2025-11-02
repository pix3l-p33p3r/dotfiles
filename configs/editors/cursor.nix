{ lib, appimageTools, fetchurl }:

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

  extraInstallCommands = ''
    # Install desktop file
    install -Dm444 ${appimageContents}/cursor.desktop -t $out/share/applications
    
    # Replace Exec line in desktop file
    substituteInPlace $out/share/applications/cursor.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=cursor' \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=cursor --no-sandbox %U'
    
    # Install icons
    for size in 16 32 48 64 128 256 512; do
      if [ -f ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/cursor.png ]; then
        install -Dm444 ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/cursor.png \
          $out/share/icons/hicolor/''${size}x''${size}/apps/cursor.png
      fi
    done
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

