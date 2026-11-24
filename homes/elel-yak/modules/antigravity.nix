{ pkgs, lib, antigravity, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  agy = antigravity.packages.${system};
  # Same cluster flags as Chrome: no setuid sandbox, software GL.
  # Do not pass ozone-platform-hint — Electron 39 rejects it as unknown.
  flags = [
    "--no-sandbox"
    "--disable-gpu"
  ];
  wrap =
    {
      name,
      package,
      bin ? name,
    }:
    pkgs.symlinkJoin {
      inherit name;
      paths = [ package ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/${bin}" \
          ${lib.concatMapStringsSep " " (f: "--add-flags ${lib.escapeShellArg f}") flags}
      '';
    };
in
{
  home.packages = [
    agy.antigravity-cli
    (wrap {
      name = "antigravity";
      package = agy.antigravity;
    })
    (wrap {
      name = "antigravity-ide";
      package = agy.antigravity-fhs;
      bin = "antigravity-ide";
    })
  ];

  # Real launchers under ~/.local — GNOME starts outside the chroot.
  # Source files live next to this module (same pattern as kitty.conf / zshenv).
  # IDE user data + extensions live on goinfre (home is ~5G).
  home.activation.antigravityLaunchers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.local/bin" /goinfre/elel-yak/antigravity-ide "/goinfre/elel-yak/config/Antigravity IDE"
    install -m755 "$HOME/dotfiles-terminal/homes/elel-yak/modules/antigravity-launcher.sh" \
      "$HOME/.local/bin/antigravity"
    install -m755 "$HOME/dotfiles-terminal/homes/elel-yak/modules/antigravity-ide-launcher.sh" \
      "$HOME/.local/bin/antigravity-ide"
    install -m755 "$HOME/dotfiles-terminal/homes/elel-yak/modules/agy-ide-update.sh" \
      "$HOME/.local/bin/agy-ide-update"
    install -Dm644 "$HOME/dotfiles-terminal/homes/elel-yak/modules/antigravity-ide.desktop" \
      "$HOME/.local/share/applications/antigravity-ide.desktop"
    # Symlink heavy IDE dirs onto goinfre if still real directories.
    if [ -d "$HOME/.antigravity-ide" ] && [ ! -L "$HOME/.antigravity-ide" ]; then
      cp -a "$HOME/.antigravity-ide/." /goinfre/elel-yak/antigravity-ide/ 2>/dev/null || true
      rm -rf "$HOME/.antigravity-ide"
    fi
    ln -sfn /goinfre/elel-yak/antigravity-ide "$HOME/.antigravity-ide"
    if [ -d "$HOME/.config/Antigravity IDE" ] && [ ! -L "$HOME/.config/Antigravity IDE" ]; then
      mkdir -p "/goinfre/elel-yak/config/Antigravity IDE"
      cp -a "$HOME/.config/Antigravity IDE/." "/goinfre/elel-yak/config/Antigravity IDE/" 2>/dev/null || true
      rm -rf "$HOME/.config/Antigravity IDE"
    fi
    ln -sfn "/goinfre/elel-yak/config/Antigravity IDE" "$HOME/.config/Antigravity IDE"
  '';
}
