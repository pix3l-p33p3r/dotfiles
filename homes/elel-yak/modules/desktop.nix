{ config, pkgs, lib, ... }:
let
  # GNOME 42 build. Shell reads ~/.local/share, not goinfre XDG_DATA_HOME.
  paperwm = pkgs.stdenv.mkDerivation {
    pname = "paperwm";
    version = "44.18.1";
    src = pkgs.fetchzip {
      url = "https://github.com/paperwm/PaperWM/archive/refs/tags/v44.18.1.tar.gz";
      sha256 = "13d44db5kmsl7zr9q5kdcmnq0i8w868af4c3v8ii6l8cinm8ca1w";
    };
    nativeBuildInputs = [ pkgs.glib ];
    installPhase = ''
      mkdir -p "$out"
      cp -a . "$out/"
      glib-compile-schemas "$out/schemas"
    '';
  };
in
{
  # GNOME Shell scans ~/.local/share/applications, not goinfre XDG_DATA_HOME.
  # Absolute profile path: a bare `google-chrome-stable` hits /opt/google/chrome.
  home.file.".local/share/applications/google-chrome.desktop".text = ''
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Google Chrome
    GenericName=Web Browser
    Comment=Google Chrome from Nix
    TryExec=/home/elel-yak/.nix-profile/bin/google-chrome-stable
    Exec=/home/elel-yak/.nix-profile/bin/google-chrome-stable %U
    Icon=/home/elel-yak/.nix-profile/share/icons/hicolor/256x256/apps/google-chrome.png
    Terminal=false
    StartupNotify=true
    StartupWMClass=Google-chrome
    Categories=Network;WebBrowser;
    MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
    Actions=new-window;new-private-window;
    Keywords=chrome;browser;

    [Desktop Action new-window]
    Name=New Window
    Exec=/home/elel-yak/.nix-profile/bin/google-chrome-stable

    [Desktop Action new-private-window]
    Name=New Incognito Window
    Exec=/home/elel-yak/.nix-profile/bin/google-chrome-stable --incognito
  '';

  # Shadow the Ubuntu package id so the app grid uses Nix Chrome too.
  home.file.".local/share/applications/com.google.Chrome.desktop".text = ''
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Google Chrome
    GenericName=Web Browser
    Comment=Google Chrome from Nix
    TryExec=/home/elel-yak/.nix-profile/bin/google-chrome-stable
    Exec=/home/elel-yak/.nix-profile/bin/google-chrome-stable %U
    Icon=/home/elel-yak/.nix-profile/share/icons/hicolor/256x256/apps/google-chrome.png
    Terminal=false
    StartupNotify=true
    StartupWMClass=Google-chrome
    Categories=Network;WebBrowser;
    NoDisplay=true
  '';

  # PaperWM lives in the home dir GNOME Shell scans.
  home.file.".local/share/gnome-shell/extensions/paperwm@paperwm.github.com" = {
    source = paperwm;
    recursive = true;
  };

  home.activation.enablePaperWM = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if command -v gnome-extensions >/dev/null 2>&1; then
      env -u XDG_DATA_HOME gnome-extensions enable paperwm@paperwm.github.com || true
    fi
  '';

  # Keep the current dock order. Add Nix Chrome if it is missing.
  home.activation.gnomeDockFavorites = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v gsettings >/dev/null 2>&1; then
      python3 - <<'PY'
    import ast, subprocess
    raw = subprocess.check_output(
        ["gsettings", "get", "org.gnome.shell", "favorite-apps"], text=True
    ).strip()
    apps = ast.literal_eval(raw)
    if "google-chrome.desktop" not in apps:
        apps.append("google-chrome.desktop")
        subprocess.check_call(
            ["gsettings", "set", "org.gnome.shell", "favorite-apps", str(apps)]
        )
    PY
    fi
  '';
}
