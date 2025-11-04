{ config, lib, ... }:
{
  programs.mpv.enable = true;

  programs.mpv.config = {
    # ═══════════════════════════════════════════════════════════
    # Hardware Acceleration (Intel Quick Sync / VA-API)
    # ═══════════════════════════════════════════════════════════
    hwdec = "auto-copy";              # Hardware decode with fallback
    vo = "gpu-next";                  # Next-gen GPU video output
    gpu-api = "vulkan";               # Use Vulkan for best performance
    gpu-context = "waylandvk";        # Wayland Vulkan context
    
    # Hardware upload for better performance
    hwdec-codecs = "all";
    
    # Vulkan optimizations
    vulkan-async-compute = "yes";
    vulkan-async-transfer = "yes";
    vulkan-queue-count = 1;
    vulkan-swap-mode = "auto";        # Auto select swap mode
    
    # ═══════════════════════════════════════════════════════════
    # Video Quality & Processing
    # ═══════════════════════════════════════════════════════════
    profile = "gpu-hq";               # High quality GPU rendering
    scale = "ewa_lanczossharp";       # High quality upscaling
    cscale = "ewa_lanczossharp";      # High quality chroma upscaling
    dscale = "mitchell";              # High quality downscaling
    
    # Debanding (remove color banding artifacts)
    deband = "yes";
    deband-iterations = 4;
    deband-threshold = 35;
    deband-range = 16;
    deband-grain = 5;
    
    # Dithering
    dither-depth = "auto";
    dither = "fruit";                 # Highest quality dithering
    
    # ═══════════════════════════════════════════════════════════
    # Display & Window
    # ═══════════════════════════════════════════════════════════
    fs = "yes";                       # Start in fullscreen
    keepaspect = "yes";               # Keep aspect ratio
    keepaspect-window = "no";         # Don't force window aspect
    
    # ═══════════════════════════════════════════════════════════
    # Performance & Caching
    # ═══════════════════════════════════════════════════════════
    cache = "yes";
    demuxer-max-bytes = "512M";       # 512MB cache
    demuxer-max-back-bytes = "128M";  # 128MB backward cache
    demuxer-readahead-secs = 20;      # Read ahead 20 seconds
    
    # ═══════════════════════════════════════════════════════════
    # UI & OSD
    # ═══════════════════════════════════════════════════════════
    osc = "no";                       # Disable OSC
    osd-bar = "yes";                  # Show OSD bar
    osd-on-seek = "bar";              # Show bar when seeking
    
    # ═══════════════════════════════════════════════════════════
    # System Integration
    # ═══════════════════════════════════════════════════════════
    stop-screensaver = "yes";

    # Saves the seekbar position on exit
    save-position-on-quit = "yes";

    # Audio
    volume = 60;
    volume-max = 100;
    alang = "ar,en,eng";

    # Hides the cursor automatically
    cursor-autohide = 100;

    # Subtitle
    sub-visibility = "no";
    sub-auto = "fuzzy";
    sub-font = lib.mkForce "Noto Sans";
    slang = "ar,en,eng";

    # Screenshots
    screenshot-format = "png";
    screenshot-high-bit-depth = "no";
    screenshot-tag-colorspace = "yes";
    screenshot-png-compression = 9;
    screenshot-directory = "~/Pictures/Screenshots/";
    screenshot-template = "mpvsnap-20%ty-%tm-%td-%tHh%tMm%tSs";
  };

  programs.mpv.bindings = {
    "q" = "quit"; # quit
    "ESC" = "set fullscreen no"; # leave fullscreen

    "h" = "no-osd seek -5"; # seek 5 seconds forward
    "l" = "no-osd seek 5"; # seek 5 seconds backward
    "k" = "add volume 5"; # volume up 5
    "j" = "add volume -5"; # volume down 5
    "m" = "no-osd cycle mute"; # toggle mute

    "[" = "multiply speed 1/1.1"; # decrease the playback speed
    "]" = "multiply speed 1.1"; # increase the playback speed
    "0" = "set speed 1.0"; # reset the speed to normal
    "." = "frame-step"; # advance one frame and pause
    "," = "frame-back-step"; # go back by one frame and pause

    "p" = "show-progress"; # "show"; = playback progress
    "s" = "screenshot"; # take a screenshot of the video in its original resolution with subtitles
    "S" = "screenshot video"; # take a screenshot of the video in its original resolution without subtitles

    "Alt+h" = "add video-pan-x  -0.1"; # move the video right
    "Alt+l" = "add video-pan-x   0.1"; # move the video left
    "Alt+k" = "add video-pan-y  -0.1"; # move the video down
    "Alt+j" = "add video-pan-y   0.1"; # move the video up
    "Alt++" = "add video-zoom    0.1"; # zoom in
    "Alt+-" = "add video-zoom   -0.1"; # zoom out
    "Alt+r" = "set video-zoom 0; set video-pan-x 0; set video-pan-y 0 "; # reset zoom and pan settings

    "Shift+j" = "cycle sub"; # switch subtitle track
    "Shift+k" = "cycle audio"; # switch audio track
    "Shift+l" = "cycle video"; # switch video track
  };
}
