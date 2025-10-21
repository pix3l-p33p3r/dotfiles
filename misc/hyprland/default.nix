{pkgs, inputs, ...}:
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
    # ./kitty/kitty.nix
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
    kitty
    macchina
    nitch
    nix-tree
    ripgrep
    starship
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
    kmon
    nvtopPackages.intel

    # --------------------------------------------------------------------------
    # |                               Wayland                                  |
    # --------------------------------------------------------------------------
    cliphist
    grim
    hyprcursor
    hypridle
    hyprland
    hyprlock
    hyprpaper
    hyprpicker
    hyprutils
    slurp
    waybar
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

    # --------------------------------------------------------------------------
    # |                              Networking                                |
    # --------------------------------------------------------------------------
    bluez
    bluez-tools
    iwd
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
    # |                               Drivers                                  |
    # --------------------------------------------------------------------------
    intel-gpu-tools
    vulkan-tools



  ];
}

