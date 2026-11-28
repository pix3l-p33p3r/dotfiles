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
  # Absolute path: GNOME outside nix-user-chroot cannot resolve theme names that
  # only exist under ~/.nix-profile (and GC'd profile gens leave blank dock icons).
  chromeIconPath = "${home}/.local/share/icons/hicolor/256x256/apps/google-chrome.png";

  chromeWrapper = pkgs.writeText "google-chrome" ''
    #!/usr/bin/env bash
    # Absolute profile path: a bare name resolves back to this wrapper via
    # ~/.local/bin in PATH and recurses until unshare fails with ENOSPC.
    bin="$HOME/.nix-profile/bin/google-chrome-stable"
    # GPU on. --no-sandbox stays: nix-user-chroot has no setuid chrome sandbox.
    # Vaapi* turns on Intel/AMD video decode. Drop these two lines if a window stays black.
    flags=(
      --no-sandbox
      --ignore-gpu-blocklist
      --enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoDecoder,VaapiIgnoreDriverChecks
    )
    # nixGLIntel supplies Nix Mesa for OpenGL. Its LIBVA path lists Mesa's
    # radeonsi driver first, so Chrome opens the AMD decoder and vaInitialize
    # fails. Force the 64-bit Intel iHD 26.3.5 directory: H.264, VP9, HEVC, AV1.
    # Do not prepend /usr/lib or Ubuntu libc wins and Chrome aborts.
    if [[ -n "''${NIX_USER_CHROOT:-}" && -x "$bin" ]]; then
      ihd_dri=$(grep -o '/nix/store/[^:]*intel-media-driver-[^:]*' \
        "$HOME/.nix-profile/bin/nixGLIntel" | head -1)
      exec "$HOME/.nix-profile/bin/nixGLIntel" \
        /usr/bin/env LIBVA_DRIVER_NAME=iHD LIBVA_DRIVERS_PATH="$ihd_dri" \
        "$bin" "''${flags[@]}" "$@"
    fi
    # Re-enter only from outside: inside with a missing profile binary this
    # wrapper would call itself until exec fails with E2BIG.
    if [[ -z "''${NIX_USER_CHROOT:-}" && -x "$HOME/.local/bin/nix-enter" ]]; then
      exec "$HOME/.local/bin/nix-enter" "$HOME/.local/bin/google-chrome" "$@"
    fi
    # Last resort: Ubuntu .deb Chrome (keeps the dock pin usable after a bad profile gen).
    if [[ -x /opt/google/chrome/google-chrome ]]; then
      exec /opt/google/chrome/google-chrome "''${flags[@]}" "$@"
    fi
    echo "google-chrome: nix profile binary missing and no system Chrome at /opt/google/chrome" >&2
    exit 127
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
    Icon=${chromeIconPath}
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
    Icon=${chromeIconPath}
    Terminal=false
    StartupNotify=true
    StartupWMClass=Google-chrome
    Categories=Network;WebBrowser;
    NoDisplay=true
  '';

  # Same override as packages.nix, so the icon comes from the store path already installed.
  cursorIde = pkgs.code-cursor.override { commandLineArgs = "--no-sandbox"; };
  grokBot = pkgs.callPackage ../../../configs/editors/grok-bot.nix { };

  desktopEntry =
    {
      id,
      name,
      comment,
      exec,
      args ? "",
      icon,
      extra ? "",
    }:
    pkgs.writeText "${id}.desktop" ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=${name}
      Comment=${comment}
      TryExec=${home}/.local/bin/${exec}
      Exec=${home}/.local/bin/${exec}${args}
      Icon=${icon}
      StartupNotify=true
      ${extra}
    '';

  icon256 = name: ".local/share/icons/hicolor/256x256/apps/${name}.png";
in
{
  # GNOME Shell scans ~/.local/share/applications, not goinfre XDG_DATA_HOME.
  # Launchers, entries and icons are real files (see note above); the dock
  # order is dconf state, declared below.
  home.hostFiles = {
    ".local/bin/google-chrome" = {
      source = chromeWrapper;
      executable = true;
    };
    ".local/bin/google-chrome-stable" = {
      source = chromeWrapper;
      executable = true;
    };
    ".local/share/applications/google-chrome.desktop".source = chromeDesktop;
    ".local/share/applications/com.google.Chrome.desktop".source = chromeDesktopHidden;

    ".local/share/applications/kitty.desktop".source = desktopEntry {
      id = "kitty";
      name = "kitty";
      comment = "Fast, feature-rich, GPU based terminal";
      exec = "kitty";
      icon = "kitty";
      extra = ''
        GenericName=Terminal emulator
        Categories=System;TerminalEmulator;
        X-TerminalArgExec=--
        X-TerminalArgTitle=--title
        X-TerminalArgAppId=--class
        X-TerminalArgDir=--working-directory
        X-TerminalArgHold=--hold
      '';
    };
    ".local/share/applications/cursor.desktop".source = desktopEntry {
      id = "cursor";
      name = "Cursor";
      comment = "The AI Code Editor";
      exec = "cursor-ide";
      args = " %F";
      icon = "${home}/${icon256 "co.anysphere.cursor"}";
      extra = ''
        Terminal=false
        StartupWMClass=Cursor
        Categories=Development;IDE;TextEditor;
        MimeType=application/x-cursor-workspace;
        Keywords=cursor;code;editor;
      '';
    };
    ".local/share/applications/grok-bot.desktop".source = desktopEntry {
      id = "grok-bot";
      name = "Grok Bot";
      comment = "Grok Bot desktop agent";
      exec = "grok-bot";
      args = " %U";
      icon = "grok-bot";
      extra = ''
        Terminal=false
        StartupWMClass=grok-bot
        Categories=Development;
        Keywords=grok;ai;agent;
        MimeType=text/html;x-scheme-handler/grokbot;x-scheme-handler/sand;
      '';
    };
    ".local/share/applications/antigravity.desktop".source = desktopEntry {
      id = "antigravity";
      name = "Antigravity";
      comment = "Google Antigravity Desktop Hub / Agent";
      exec = "antigravity";
      args = " %u";
      icon = "antigravity";
      extra = ''
        Terminal=false
        StartupWMClass=antigravity
        Categories=Development;
        MimeType=x-scheme-handler/antigravity;
        Keywords=antigravity;google;agent;
      '';
    };

    ${icon256 "kitty"}.source = "${pkgs.kitty}/share/icons/hicolor/256x256/apps/kitty.png";
    ${icon256 "grok-bot"}.source = "${grokBot}/share/icons/hicolor/256x256/apps/grok-bot.png";
    ${icon256 "co.anysphere.cursor"}.source = "${cursorIde}/share/pixmaps/cursor.png";
    ${icon256 "antigravity"}.source = ../assets/icons/antigravity.png;
    ${icon256 "antigravity-ide"}.source = ../assets/icons/antigravity-ide.png;
  };

  # Chrome ships icons at several sizes; copy whichever exist.
  home.activation.nixChromeIcons = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for size in 16 24 32 48 64 128 256; do
      dest="$HOME/.local/share/icons/hicolor/''${size}x''${size}/apps"
      run mkdir -p "$dest"
      run rm -f "$dest/google-chrome.png"
      if [[ -f "${pkgs.google-chrome}/share/icons/hicolor/''${size}x''${size}/apps/google-chrome.png" ]]; then
        run cp -L "${pkgs.google-chrome}/share/icons/hicolor/''${size}x''${size}/apps/google-chrome.png" "$dest/google-chrome.png"
      elif [[ -f /usr/share/icons/hicolor/''${size}x''${size}/apps/google-chrome.png ]]; then
        run cp -L /usr/share/icons/hicolor/''${size}x''${size}/apps/google-chrome.png "$dest/google-chrome.png"
      elif [[ -f /opt/google/chrome/product_logo_''${size}.png ]]; then
        run cp -L /opt/google/chrome/product_logo_''${size}.png "$dest/google-chrome.png"
      fi
      run chmod 644 "$dest/google-chrome.png" 2>/dev/null || true
    done
    run rm -f "$HOME/.local/share/icons/hicolor/icon-theme.cache"
  '';

  dconf.settings."org/gnome/shell".favorite-apps = [
    "kitty.desktop"
    "cursor.desktop"
    "grok-bot.desktop"
    "org.gnome.Nautilus.desktop"
    "google-chrome.desktop"
    "antigravity.desktop"
    "antigravity-ide.desktop"
    "codex-desktop.desktop"
    "org.kicad.kicad.desktop"
  ];
}
