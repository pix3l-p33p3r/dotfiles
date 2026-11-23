{ pkgs, lib, codex-desktop-linux, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  codexDesktopPkg = codex-desktop-linux.packages.${system}.codex-desktop;
  # Cluster Electron flags (no setuid sandbox, software GL — matches Chrome & Antigravity).
  flags = [
    "--no-sandbox"
    "--disable-gpu"
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
  # Keep ~/.codex and Electron profile data on goinfre (home quota is ~5G).
  home.activation.codexLaunchers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.local/bin" \
      /goinfre/elel-yak/codex \
      /goinfre/elel-yak/config/Codex \
      "/goinfre/elel-yak/config/ChatGPT Community"

    install -m755 "$HOME/dotfiles-terminal/homes/elel-yak/modules/codex-desktop-launcher.sh" \
      "$HOME/.local/bin/codex-desktop"
    install -Dm644 "$HOME/dotfiles-terminal/homes/elel-yak/modules/codex-desktop.desktop" \
      "$HOME/.local/share/applications/codex-desktop.desktop"
    install -Dm644 "${codexDesktopPkg}/share/icons/hicolor/256x256/apps/codex-desktop.png" \
      "$HOME/.local/share/icons/hicolor/256x256/apps/codex-desktop.png"

    if [ -d "$HOME/.codex" ] && [ ! -L "$HOME/.codex" ]; then
      cp -a "$HOME/.codex/." /goinfre/elel-yak/codex/ 2>/dev/null || true
      rm -rf "$HOME/.codex"
    fi
    ln -sfn /goinfre/elel-yak/codex "$HOME/.codex"

    if [ -d "$HOME/.config/Codex" ] && [ ! -L "$HOME/.config/Codex" ]; then
      cp -a "$HOME/.config/Codex/." /goinfre/elel-yak/config/Codex/ 2>/dev/null || true
      rm -rf "$HOME/.config/Codex"
    fi
    ln -sfn /goinfre/elel-yak/config/Codex "$HOME/.config/Codex"
  '';
}
