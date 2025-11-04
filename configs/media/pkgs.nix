{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # ============================================================================
    # |                              MEDIA TOOLS                               |
    # ============================================================================
    # Video & Audio Processing
    ffmpeg # Media converter and processing
    yt-dlp # YouTube and video downloader
    spotdl # Spotify downloader
    
    # Image Manipulation
    imagemagick # Image manipulation suite
    imv # Lightweight image viewer
    
    # Media Players
    vlc # VLC media player (mpv is handled by mpv.nix)
    
    # Audio Visualization
    cava # Audio visualizer for terminal
    
    # Music Players & Daemon
    rmpc # Rust MPD client (config in rmpc.nix)
    kew # Terminal music player (config in kew.nix)
    mpd # Music Player Daemon
    
    # ============================================================================
    # |                            DOCUMENT TOOLS                              |
    # ============================================================================
    pandoc # Universal document converter
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

