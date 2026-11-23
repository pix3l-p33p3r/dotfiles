{ config, pkgs, lib, ... }:
let
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
    # Absolute profile path: a bare name resolves back to this wrapper via
    # ~/.local/bin in PATH and recurses until unshare fails with ENOSPC.
    bin="$HOME/.nix-profile/bin/google-chrome-stable"
    flags=(--no-sandbox --disable-gpu)
    if [[ -x "$bin" ]]; then
      exec "$bin" "''${flags[@]}" "$@"
    fi
    exec "$HOME/.local/bin/nix-enter" "$bin" "''${flags[@]}" "$@"
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

  # Keep the current dock order and pin Nix Chrome right after grok-bot,
  # plus Codex Desktop after Antigravity IDE.
  # Known-good order: kitty, cursor, grok-bot, google-chrome, Nautilus,
  # antigravity, antigravity-ide, codex-desktop.
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
codex = "codex-desktop.desktop"
if codex in apps:
    apps.remove(codex)
if "antigravity-ide.desktop" in apps:
    apps.insert(apps.index("antigravity-ide.desktop") + 1, codex)
else:
    apps.append(codex)
subprocess.check_call(
    ["gsettings", "set", "org.gnome.shell", "favorite-apps", str(apps)]
)
PY
    fi
  '';
}
