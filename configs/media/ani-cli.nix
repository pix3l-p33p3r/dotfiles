{ pkgs, ... }:
{
  # Slim ani-cli + player/downloader deps for cluster and alucard.
  # Pin still evaluates ani-cli 4.14 (dead allanime). Official nixpkgs
  # package on nixos-unstable is 5.1 (hianime). Same expression, newer src.
  # hls.aniwatch.al serves a Cloudflare Origin cert (curl 60); skip TLS
  # verify on scrape + mpv until the CDN presents a public cert.
  home.packages = with pkgs; [
    mpv
    yt-dlp
    ((callPackage (fetchurl {
      name = "ani-cli-package.nix";
      url = "https://raw.githubusercontent.com/NixOS/nixpkgs/7a0f122f5090cf4c2ade2a13a0e229d4e19ba71f/pkgs/by-name/an/ani-cli/package.nix";
      hash = "sha256-kvI4u6oc1VjutB/HilIuLpoRQ2UfILGRYczvHvyzsD8=";
    }) { }).overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace ani-cli \
          --replace-fail '$curl_exe -sL -A "$agent"' '$curl_exe -k -sL -A "$agent"'
      '';
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/ani-cli \
          --set ANI_CLI_PLAYER_FLAGS "--tls-verify=no"
      '';
    }))
  ];
}
