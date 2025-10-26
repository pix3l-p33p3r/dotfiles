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
	# |                        DevOps & Infrastructure                         |
	# --------------------------------------------------------------------------
	# Container & Orchestration
	docker
	docker-compose
	podman
	podman-compose
	helm
	kustomize
	minikube
	kind
	k3s
	k9s
	
	# Infrastructure as Code
	terraform
	terraform-ls
	terragrunt
	pulumi
	ansible
	ansible-lint
	
	# CI/CD & Build Tools
	gitlab-runner
	github-runner
	buildah
	skopeo
	crane
	
	# Monitoring & Observability
	prometheus
	grafana
	loki
	promtail
	prometheus-node-exporter
	cadvisor
	
	# Cloud & API Tools
	awscli2
	azure-cli
	google-cloud-sdk
	doctl
	linode-cli
	vultr-cli
	
	# Network & Security Tools
	nmap
	wireshark-cli
	tcpdump
	netcat
	openssl
	httpie
	
	# --------------------------------------------------------------------------
	# |                        DevSecOps & Security                           |
	# --------------------------------------------------------------------------
	# Security Scanning
	trivy
	grype
	syft
	semgrep
	bandit
	pip-audit
	
	# Secrets Management
	vault
	sops
	age
	gopass
	pass
	keychain
	
	# Security Analysis
	nuclei
	subfinder
	amass
	assetfinder
	waybackurls
	gau
	ffuf
	gobuster
	dirb
	nikto
	
	# --------------------------------------------------------------------------
	# |                      Low-Level & Robotics                             |
	# --------------------------------------------------------------------------
	# Embedded Development
	gcc-arm-embedded
	openocd
	qemu
	
	# Microcontroller Tools
	avrdude
	picocom
	minicom
	screen
	
	# Hardware Debugging
	sigrok-cli
	pulseview
	gtkwave
	iverilog
	
	# --------------------------------------------------------------------------
	# |                        System & Performance                           |
	# --------------------------------------------------------------------------
	# System Monitoring
	iotop
	vnstat
	perf
	strace
	ltrace
	
	# Process & Memory Analysis
	psmisc
	procps
	memtest86plus
	stress-ng
	
	# File System Tools
	ntfs3g
	exfat
	f2fs-tools
	xfsprogs
	btrfs-progs
	e2fsprogs
	
	# --------------------------------------------------------------------------
	# |                        Development Utilities                           |
	# --------------------------------------------------------------------------
	# Version Control
	git-lfs
	git-crypt
	git-secrets
	gh
	glab
	
	# Code Quality & Linting
	shellcheck
	shfmt
	hadolint
	yamllint
	checkstyle
	eslint
	prettier
	
	# Build Tools
	cmake
	ninja
	meson
	pkg-config
	
	# Package Managers
	pipx
	cargo
	go
	nodejs
	yarn
	pnpm
	
	# --------------------------------------------------------------------------
	# |                            TUI Applications                            |
	# --------------------------------------------------------------------------

	
	# Network Tools
	bandwhich
	slurm
	speedtest-cli
	
	# Database Tools
	mycli
	pgcli
	litecli
	usql
	
	# Git TUI Tools
	tig
	git-interactive-rebase-tool
	
	# Development TUI
	stern

	# --------------------------------------------------------------------------
	# |                            System & Hardware                           |
	# --------------------------------------------------------------------------
	acpi
	btop
	brightnessctl
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
	gitui


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
