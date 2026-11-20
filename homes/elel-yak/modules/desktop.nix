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

  home = config.home.homeDirectory;

  # IMPORTANT (do not regress): the Chrome wrapper + .desktop files MUST end up
  # as REAL files under ~/.local, NOT as home.file symlinks. home.file points
  # into /nix/store, and gnome-shell runs OUTSIDE the nix-user-chroot where /nix
  # does not exist, so it cannot follow those symlinks and HIDES the app (same
  # reason paperwm's metadata.json symlink fails to load). We build the content
  # in the store and `install` (copy) it to a plain file in activation.
  #
  # The wrapper's shebang is /usr/bin/env bash (a real path outside the chroot),
  # and it re-enters the chroot via ~/.local/bin/nix-enter so /nix/store Chrome
  # is reachable when launched from the GNOME dash.
  chromeWrapper = pkgs.writeText "google-chrome" ''
    #!/usr/bin/env bash
    exec "$HOME/.local/bin/nix-enter" google-chrome-stable --no-sandbox --disable-gpu "$@"
  '';

  chromeDesktop = pkgs.writeText "google-chrome.desktop" ''
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Google Chrome
    GenericName=Web Browser
    Comment=Google Chrome from Nix
    TryExec=${home}/.local/bin/google-chrome
    Exec=${home}/.local/bin/google-chrome %U
    Icon=google-chrome
    Terminal=false
    StartupNotify=true
    StartupWMClass=Google-chrome
    Categories=Network;WebBrowser;
    MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
    Actions=new-window;new-private-window;
    Keywords=chrome;browser;

    [Desktop Action new-window]
    Name=New Window
    Exec=${home}/.local/bin/google-chrome

    [Desktop Action new-private-window]
    Name=New Incognito Window
    Exec=${home}/.local/bin/google-chrome --incognito
  '';

  # Shadow the Ubuntu package id so the app grid uses Nix Chrome too (hidden).
  chromeDesktopHidden = pkgs.writeText "com.google.Chrome.desktop" ''
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Google Chrome
    GenericName=Web Browser
    Comment=Google Chrome from Nix
    TryExec=${home}/.local/bin/google-chrome
    Exec=${home}/.local/bin/google-chrome %U
    Icon=google-chrome
    Terminal=false
    StartupNotify=true
    StartupWMClass=Google-chrome
    Categories=Network;WebBrowser;
    NoDisplay=true
  '';
in
{
  # GNOME Shell scans ~/.local/share/applications, not goinfre XDG_DATA_HOME.
  # Install Chrome launcher + desktop entries as REAL files (see note above).
  home.activation.nixChromeDesktop = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -Dm755 ${chromeWrapper} "$HOME/.local/bin/google-chrome"
    run install -Dm644 ${chromeDesktop} "$HOME/.local/share/applications/google-chrome.desktop"
    run install -Dm644 ${chromeDesktopHidden} "$HOME/.local/share/applications/com.google.Chrome.desktop"
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

  # Keep the current dock order and pin Nix Chrome right after grok-bot.
  # Known-good order: kitty, cursor, grok-bot, google-chrome, Nautilus,
  # antigravity, antigravity-ide.
  home.activation.gnomeDockFavorites = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v gsettings >/dev/null 2>&1; then
      python3 - <<'PY'
import ast, subprocess
raw = subprocess.check_output(
    ["gsettings", "get", "org.gnome.shell", "favorite-apps"], text=True
).strip()
apps = ast.literal_eval(raw)
chrome = "google-chrome.desktop"
anchor = "grok-bot.desktop"
if chrome in apps:
    apps.remove(chrome)
if anchor in apps:
    apps.insert(apps.index(anchor) + 1, chrome)
else:
    apps.append(chrome)
subprocess.check_call(
    ["gsettings", "set", "org.gnome.shell", "favorite-apps", str(apps)]
)
PY
    fi
  '';
}
