{
  pkgs,
  lo-pkgs,
  inputs,
  host,
  ...
}:
{

  imports = [
    # inputs.sherlock.homeModules.default
    inputs.stylix.homeModules.stylix

    # import home manager custom modules
    # ../../../../modules/hm

    # ../../common

    # Hyprland config
    ./hyprland.nix

    # Fonts and GTK theming
    ./fonts.nix
    ./theming.nix

    # XDG stuff
    ./xdg.nix

    # Applets
    ./applets

    # ./browsers/firefox.nix
    ./kitty.nix
    ./zsh
    ./mpv.nix
    ./imv.nix
    ./zathura.nix

    ./nvim
  ];

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
    gvfs
    kmon
    libgtop
    nvtopPackages.intel
    power-profiles-daemon
    s-tui
    upower

    # --------------------------------------------------------------------------
    # |                               Wayland                                  |
    # --------------------------------------------------------------------------
    cliphist
    grim
    grimblast
    hyprcursor
    hypridle
    hyprland
    hyprlock
    hyprpaper
    hyprpicker
    hyprpanel
    hyprshot
    hyprsunset
    hyprutils
    slurp
    waybar
    wl-clipboard
    wl-clip-persist
    wl-color-picker
    wofi
    wofi-emoji
    lo-pkgs.realod-failed-services

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
    wireplumber

    # --------------------------------------------------------------------------
    # |                              Networking                                |
    # --------------------------------------------------------------------------
    bluez
    bluez-tools
    iwd
    networkmanager
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
    aylurs-gtk-shell-git
    
    # DEV (Development)
    code-cursor
    gcc
    gemini-cli
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

    fabric-ai

    # --------------------------------------------------------------------------
    # |                          Development & Libraries                        |
    # --------------------------------------------------------------------------
    dart-sass
    gtksourceview3
    libsoup3

    # --------------------------------------------------------------------------
    # |                               Drivers                                  |
    # --------------------------------------------------------------------------
    intel-gpu-tools
    vulkan-tools



  ];
}

