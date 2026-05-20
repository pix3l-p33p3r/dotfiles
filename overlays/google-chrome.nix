# Bump google-chrome to 148.0.7778.178 (released by Google 2026-05-19).
# Upstream nixpkgs commit 68ed617 landed the bump on master but it has not
# rolled into the `nixos-unstable` channel yet. Remove this overlay once
# the channel catches up.
final: prev: {
  google-chrome = prev.google-chrome.overrideAttrs (_old: rec {
    version = "148.0.7778.178";

    src = prev.fetchurl {
      url = "https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${version}-1_amd64.deb";
      hash = "sha256-3iuKxcuwt/+BIcUqC715hbeRLhUjepNU1GbB3daIokI=";
    };
  });
}
