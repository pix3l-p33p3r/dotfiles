# Cargo vendor layout gained an extra directory level (NixOS/nixpkgs#387337);
# stremio-linux-shell postPatch globs were fixed in nixpkgs#503035. Pin older
# nixpkgs until `nix flake update` picks up that commit.
final: prev: {
  stremio-linux-shell = prev.stremio-linux-shell.overrideAttrs (old: {
    postPatch = ''
      substituteInPlace src/config.rs \
        --replace-fail "@serverjs@" "${placeholder "out"}/share/stremio/server.js"

      substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
        --replace-fail "libayatana-appindicator3.so.1" "${prev.libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
      substituteInPlace $cargoDepsCopy/*/xkbcommon-dl-*/src/lib.rs \
        --replace-fail "libxkbcommon.so.0" "${prev.libxkbcommon}/lib/libxkbcommon.so.0"
      substituteInPlace $cargoDepsCopy/*/xkbcommon-dl-*/src/x11.rs \
        --replace-fail "libxkbcommon-x11.so.0" "${prev.libxkbcommon}/lib/libxkbcommon-x11.so.0"
    '';
  });
}
