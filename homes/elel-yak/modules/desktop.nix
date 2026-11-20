{ config, pkgs, lib, ... }:
{
  # Desktop entries → XDG applications (GNOME dock favorites)
  xdg.desktopEntries.google-chrome = {
    name = "Google Chrome";
    genericName = "Web Browser";
    comment = "Google Chrome (nix / home-manager)";
    exec = "${pkgs.google-chrome}/bin/google-chrome-stable %U";
    icon = "google-chrome";
    terminal = false;
    categories = [
      "Network"
      "WebBrowser"
    ];
    mimeType = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
    settings = {
      StartupWMClass = "Google-chrome";
    };
    actions = {
      new-window = {
        name = "New Window";
        exec = "${pkgs.google-chrome}/bin/google-chrome-stable";
      };
      new-private-window = {
        name = "New Incognito Window";
        exec = "${pkgs.google-chrome}/bin/google-chrome-stable --incognito";
      };
    };
  };

  # Pin favorites (GNOME). Requires session; activation is best-effort.
  home.activation.gnomeDockFavorites = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v gsettings >/dev/null 2>&1; then
      gsettings set org.gnome.shell favorite-apps \
        "['org.gnome.Nautilus.desktop', 'kitty.desktop', 'google-chrome.desktop', 'cursor.desktop', 'grok-bot.desktop', 'antigravity.desktop', 'antigravity-ide.desktop']" \
        || true
    fi
  '';
}
