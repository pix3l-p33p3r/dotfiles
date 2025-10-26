{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # --------------------------------------------------------------------------
    # |                                CLI Base                                |
    # --------------------------------------------------------------------------
    bzip2
    curl
    direnv
    git
    gnutar
    jq
    p7zip
    unrar
    unzip
    wget
    xdg-utils

    # --------------------------------------------------------------------------
    # |                         Shell & CLI Tools                              |
    # --------------------------------------------------------------------------
    atuin
    bat
    bb
    eza
    fastfetch
    fd
    fzf
    gping
    macchina
    nitch
    nix-tree
    ripgrep
    tldr
    tmux
    trashy
    tree
    tt
    ueberzugpp
    yazi
    zoxide

    # --------------------------------------------------------------------------
    # |                            System & Hardware                           |
    # --------------------------------------------------------------------------
    acpi
    brightnessctl
    btop
    gvfs # Virtual filesystem support
    kmon
    libgtop # System monitoring library
    nvtopPackages.intel
    power-profiles-daemon # Power management daemon
    s-tui # System monitoring TUI
    upower # Power management daemon

    # --------------------------------------------------------------------------
    # |                               Wayland                                  |
    # --------------------------------------------------------------------------
    cliphist
    grim
    grimblast # Grim screenshot utility with blast functionality
    hyprcursor
    hypridle
    hyprland
    hyprlock
    hyprpaper
    hyprpicker
    hyprpanel # Hyprland panel
    hyprshot # Hyprland screenshot tool
    hyprsunset # Hyprland night light
    hyprutils
    slurp
    wl-clipboard
    wl-clip-persist
    wl-color-picker
    wofi
    wofi-emoji


    # --------------------------------------------------------------------------
    # |                                Audio                                   |
    # --------------------------------------------------------------------------
    alsa-firmware
    alsa-tools
    cava
    pamixer
    pavucontrol
    pipewire
    playerctl
    wireplumber # PipeWire session manager

    # --------------------------------------------------------------------------
    # |                              Networking                                |
    # --------------------------------------------------------------------------
    bluez
    bluez-tools
    iwd
    networkmanager # Network management daemon
    networkmanagerapplet

    # --------------------------------------------------------------------------
    # |                             File Manager                               |
    # --------------------------------------------------------------------------
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    xfce.tumbler

    # --------------------------------------------------------------------------
    # |                            Media & Documents                           |
    # --------------------------------------------------------------------------
    ffmpeg
    imagemagick
    imv
    mpv
    pandoc
    poppler
    resvg
    vlc
    zathura

    # --------------------------------------------------------------------------
    # |                           GUI Applications                             |
    # --------------------------------------------------------------------------
    # DEV (Development)
    code-cursor
    gcc
    gitui
    lazygit

    # Notes
    joplin-desktop
    notesnook
    obsidian

    # Anime & Manga
    ani-cli
    komikku

    # Privacy, Anonymity & OpSec (Operational Security)
    librewolf
    mullvad-browser
    onionshare-gui
    tor

    # ComSec (Secure Communication)
    session-desktop
    simplex-chat-desktop

    # Security
    gpa
    keepassxc
    picocrypt

    # General Utilities & Social
    discord
    hackgregator # RSS
    puffin
    spotify
    syncthing
    taskwarrior3

    # --------------------------------------------------------------------------
    # |                               AI                                       |
    # --------------------------------------------------------------------------
    gemini-cli
    fabric-ai

    # --------------------------------------------------------------------------
    # |                          Development & Libraries                        |
    # --------------------------------------------------------------------------
    dart-sass
    gtksourceview3
    libsoup_3

    # --------------------------------------------------------------------------
    # |                               Drivers                                  |
    # --------------------------------------------------------------------------
    intel-gpu-tools
    vulkan-tools
  ];
}
