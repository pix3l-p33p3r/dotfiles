{ pkgs, ... }:
{
  # Import modular package configurations
  imports = [
    ../../../development/pkgs.nix
    ../../../devops/pkgs.nix
    ../../../security/pkgs.nix
    ../../../media/pkgs.nix
  ];

  home.packages = with pkgs; [
    # ============================================================================
    # |                              CORE UTILITIES                             |
    # ============================================================================
    # Archive & Compression
    bzip2 # Compression utility
    unrar # RAR archive extractor
    unzip # ZIP archive extractor

    # Network & HTTP
    curl # HTTP client
    jq # JSON processor
    wget # File downloader

    # Desktop Integration
    xdg-utils # Desktop integration utilities

    # ============================================================================
    # |                        EMBEDDED & HARDWARE                              |
    # ============================================================================
    # Embedded Development
    gcc-arm-embedded # ARM cross-compiler
    openocd # On-chip debugging
    qemu # Virtualization platform

    # Microcontroller Tools
    avrdude # AVR programmer
    picocom # Serial terminal
    minicom # Serial communication

    # Hardware Debugging
    sigrok-cli # Logic analyzer
    pulseview # Logic analyzer GUI
    gtkwave # Waveform viewer
    iverilog # Verilog simulator

    # ============================================================================
    # |                        SYSTEM & PERFORMANCE                            |
    # ============================================================================
    # System Monitoring
    iotop # I/O monitoring
    vnstat # Network traffic monitor
    perf # Performance profiler
    strace # System call tracer
    ltrace # Library call tracer
    btop # System monitor
    s-tui # System monitoring TUI

    # Process & Memory Analysis
    procps # Process utilities
    memtest86plus # Memory tester
    stress-ng # System stress tester

    # File System Tools
    ntfs3g # NTFS support
    exfat # exFAT support
    f2fs-tools # F2FS utilities
    xfsprogs # XFS utilities
    btrfs-progs # Btrfs utilities
    e2fsprogs # ext2/3/4 utilities

    # Hardware Monitoring
    acpi # ACPI utilities
    brightnessctl # Brightness control
    dysk # Disk usage analyzer
    kmon # Kernel monitor
    libgtop # System monitoring library
    nvtopPackages.intel # Intel GPU monitoring
    power-profiles-daemon # Power management daemon
    upower # Power management daemon

    # ============================================================================
    # |                            TERMINAL APPLICATIONS                        |
    # ============================================================================
    # Shell & CLI Tools
    atuin # Shell history search
    bat # Cat with syntax highlighting
    bb # Command line tool
    eza # Modern ls replacement
    fzf # Fuzzy finder
    glow # Markdown viewer
    gping # Ping with graph
    macchina # System information
    nix-tree # Nix dependency tree
    tldr # Simplified man pages
    tmux # Terminal multiplexer
    trashy # Trash utility
    tree # Directory tree
    tt # Terminal typing test
    ueberzugpp # Image preview
    yazi # File manager
    zoxide # Smart cd

    # Development TUI
    lazygit # Git TUI
    lazysql # SQL database TUI
    lazyjournal # Journal TUI

    # Network TUI Tools
    bandwhich # Network utilization
    slurm # Network monitor
    speedtest-cli # Internet speed test

    # Database TUI Tools
    mycli # MySQL CLI
    pgcli # PostgreSQL CLI
    litecli # SQLite CLI
    usql # Universal SQL CLI

    # Terminal Applications
    terminal-stocks # Stock market TUI
    warp-terminal # Modern terminal
    sshs # SSH session manager
    terminal-parrot # Terminal parrot animation
    deskew # Image deskewing tool
    youtube-tui # YouTube TUI client
    wander # Terminal wanderer game
    tui-journal # Journal TUI
    tftui # Terminal file transfer TUI
    # spotify-tui # Spotify TUI client - package not available

    # ============================================================================
    # |                              WAYLAND DESKTOP                           |
    # ============================================================================
    # Hyprland
    hyprland # Wayland compositor
    hypridle # Hyprland idle daemon
    hyprlock # Hyprland screen locker
    hyprpaper # Hyprland wallpaper daemon
    hyprpicker # Hyprland color picker
    hyprpanel # Hyprland panel
    hyprshot # Hyprland screenshot tool
    hyprsunset # Hyprland night light
    hyprutils # Hyprland utilities
    hyprcursor # Hyprland cursor

    # Wayland Utilities
    cliphist # Clipboard history
    grim # Screenshot tool
    grimblast # Grim screenshot utility with blast functionality
    slurp # Screen area selection
    wl-clipboard # Wayland clipboard
    wl-clip-persist # Persistent clipboard
    wl-color-picker # Wayland color picker

    # ============================================================================
    # |                                AUDIO                                  |
    # ============================================================================
    alsa-firmware # ALSA firmware
    alsa-tools # ALSA utilities
    cava # Audio visualizer
    pamixer # PulseAudio mixer
    pavucontrol # PulseAudio control
    pipewire # Audio server
    playerctl # Media player control
    wireplumber # PipeWire session manager

    # ============================================================================
    # |                              NETWORKING                               |
    # ============================================================================
    bluez # Bluetooth stack
    bluez-tools # Bluetooth utilities
    networkmanager # Network management daemon
    networkmanagerapplet # NetworkManager applet
    wifi-qr # Generate WiFi QR codes

    # ============================================================================
    # |                           GUI APPLICATIONS                             |
    # ============================================================================
    # Development
    cursor-cli # Cursor CLI

    # Browsers
    qutebrowser # Keyboard-driven browser
    librewolf # Privacy-focused browser
    mullvad-browser # Privacy browser

    # Note Taking
    joplin-desktop # Note-taking app
    notesnook # Note-taking app
    obsidian # Knowledge management

    # Entertainment
    ani-cli # Anime streaming CLI
    komikku # Manga reader

    # Privacy & Security
    onionshare-gui # Secure file sharing
    tor # Anonymous network
    gpa # GNU Privacy Assistant
    keepassxc # Password manager
    picocrypt # File encryption

    # Communication
    session-desktop # Secure messaging
    simplex-chat-desktop # Secure chat
    vesktop # Discord alternative

    # Productivity
    hackgregator # RSS aggregator
    puffin # RSS reader
    spotify # Music streaming
    syncthing # File synchronization
    taskwarrior3 # Task management
    timewarrior # Time tracking
    tmux # Terminal multiplexer

    # ============================================================================
    # |                                 AI                                    |
    # ============================================================================
    gemini-cli # Google Gemini CLI
    fabric-ai # AI framework

    # ============================================================================
    # |                               DRIVERS                                 |
    # ============================================================================
    intel-gpu-tools # Intel GPU utilities
    vulkan-tools # Vulkan utilities
  ];
}
