{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # ============================================================================
    # |                              MEDIA TOOLS                               |
    # ============================================================================
    # Video & Audio Processing
    ffmpeg # Media converter and processing
    
    # Image Manipulation
    imagemagick # Image manipulation suite
    imv # Lightweight image viewer
    
    # Media Players
    vlc # VLC media player (mpv is handled by mpv.nix)
    
    # Audio Visualization
    cava # Audio visualizer for terminal
    
    # Music Players, Daemons, Downloaders & Streaming
    rmpc      # Rust MPD client (see: rmpc.nix for config)
    kew       # Terminal music player (see: kew.nix for config)
    mpd       # Music Player Daemon
    termusic  # Terminal music player
    yt-dlp    # YouTube and video downloader
    spotdl    # Spotify downloader
    spotify   # Spotify client (streaming)
    stremio-linux-shell # Stremio (replaces removed qt5-webengine stremio package)
    # Pin still evaluates ani-cli 4.14 (dead allanime). Official nixpkgs
    # package on nixos-unstable is 5.1 (hianime). Same expression, newer src.
    # hls.aniwatch.al serves a Cloudflare Origin cert (curl 60); skip TLS
    # verify on scrape + mpv until the CDN presents a public cert.
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
    
    # ============================================================================
    # |                            DOCUMENT TOOLS                              |
    # ============================================================================
    pandoc # Universal document converter
    # scheme-medium covers standard pandoc->PDF (xelatex/lualatex/pdflatex,
    # latexmk, common packages, fonts) at a fraction of scheme-full's ~7 GiB
    # closure. `tectonic` (below) is a self-contained fallback that fetches any
    # missing LaTeX packages on demand. Bump back to scheme-full only if a build
    # errors on a missing .sty.
    texlive.combined.scheme-medium # TeX Live (medium scheme)
    katex # KaTeX CLI and assets for HTML math
    mermaid-cli # mmdc: Mermaid CLI for diagrams
    graphviz # dot: Graphviz for diagrams
    # haskellPackages.pandoc-crossref removed (was ~6 GiB transitive via ghc);
    # pandoc itself is kept for general doc conversion. If crossref needed later,
    # it can be added back (or use pandoc's built-in for simple cases).
    tectonic # Fast LaTeX engine (optional alternative to texlive engines)
    poppler # PDF rendering library and utilities
    resvg # SVG renderer
    # Note: zathura is installed in zathura.nix
    
    # ============================================================================
    # |                            METADATA TOOLS                              |
    # ============================================================================
    exiftool # Read and write meta information in files
    exiv2 # Image metadata library and tools
    mat2 # Metadata anonymization toolkit
    
    # Python packages for media scripting
    python3Packages.eyed3 # MP3 tag manipulation for scripts
  ];
}

