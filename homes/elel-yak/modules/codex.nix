{ pkgs, lib, codex-desktop-linux, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  codexDesktopPkg = codex-desktop-linux.packages.${system}.codex-desktop;
  # Cluster Electron flags. No setuid sandbox. GPU stays on (same as Chrome).
  flags = [
    "--no-sandbox"
    "--ignore-gpu-blocklist"
  ];
  codexDesktopWrapped = pkgs.symlinkJoin {
    name = "codex-desktop";
    paths = [ codexDesktopPkg ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/codex-desktop" \
        ${lib.concatMapStringsSep " " (f: "--add-flags ${lib.escapeShellArg f}") flags}
    '';
  };
in
{
  home.packages = [
    pkgs.codex # OpenAI Codex terminal agent (`codex`)
    codexDesktopWrapped # Codex / ChatGPT Desktop (`codex-desktop`)
  ];

  # Real launcher + .desktop under ~/.local (GNOME runs outside nix-user-chroot).
  home.hostFiles = {
    ".local/bin/codex-desktop" = {
      source = ./codex-desktop-launcher.sh;
      executable = true;
    };
    ".local/share/applications/codex-desktop.desktop".source = ./codex-desktop.desktop;
    ".local/share/icons/hicolor/256x256/apps/codex-desktop.png".source =
      "${codexDesktopPkg}/share/icons/hicolor/256x256/apps/codex-desktop.png";
  };

  # Keep ~/.codex and Electron profile data on goinfre (home quota is ~5G).
  home.activation.codexLaunchers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p /goinfre/elel-yak/codex \
      /goinfre/elel-yak/config/Codex \
      "/goinfre/elel-yak/config/ChatGPT Community"

    # Never symlink ~/.codex. Codex bwrap RO-protects through that link and
    # then refuses queue sqlite writes ("Queue storage could not be written").
    # Sessions stay at /goinfre/elel-yak/codex via CODEX_HOME in the launcher.
    if [ -d "$HOME/.codex" ] && [ ! -L "$HOME/.codex" ]; then
      cp -a "$HOME/.codex/." /goinfre/elel-yak/codex/ 2>/dev/null || true
      chmod -R u+w "$HOME/.codex" 2>/dev/null || true
      rm -rf "$HOME/.codex" 2>/dev/null || mv "$HOME/.codex" "$HOME/.codex.old.$$"
    fi
    if [ -L "$HOME/.codex" ]; then
      rm -f "$HOME/.codex"
    fi

    if [ -d "$HOME/.config/Codex" ] && [ ! -L "$HOME/.config/Codex" ]; then
      cp -a "$HOME/.config/Codex/." /goinfre/elel-yak/config/Codex/ 2>/dev/null || true
      chmod -R u+w "$HOME/.config/Codex" 2>/dev/null || true
      rm -rf "$HOME/.config/Codex" 2>/dev/null || mv "$HOME/.config/Codex" "$HOME/.config/Codex.old.$$"
    fi
    ln -sfn /goinfre/elel-yak/config/Codex "$HOME/.config/Codex"
  '';
}
