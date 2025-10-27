{ pkgs, ... }:
{
  home.packages = with pkgs; [
	# --------------------------------------------------------------------------
	# |                                CLI Base                                |
	# --------------------------------------------------------------------------
	bzip2 # Compression utility
	curl # HTTP client
	gnutar # Archive utility
	jq # JSON processor
	p7zip # Archive utility
	unrar # RAR archive extractor
	unzip # ZIP archive extractor
	wget # HTTP downloader
	xdg-utils # Desktop integration utilities


	# --------------------------------------------------------------------------
	# |                        DevOps & Infrastructure                         |
	# --------------------------------------------------------------------------
	# Container & Orchestration
	docker # Container runtime
	docker-compose # Multi-container orchestration
	podman # Container runtime
	podman-compose # Podman compose
	helm # Kubernetes package manager
	kustomize # Kubernetes configuration management
	minikube # Local Kubernetes
	kind # Kubernetes in Docker
	k3s # Lightweight Kubernetes
	k9s # Kubernetes TUI
	
	# Infrastructure as Code
	terraform # Infrastructure provisioning
	terraform-ls # Terraform language server
	terragrunt # Terraform wrapper
	pulumi # Infrastructure as code
	ansible # Configuration management
	ansible-lint # Ansible linting
	
	# CI/CD & Build Tools
	gitlab-runner # GitLab CI runner
	github-runner # GitHub Actions runner
	buildah # Container image builder
	skopeo # Container image operations
	crane # Container registry operations
	
	# Monitoring & Observability
	prometheus # Metrics collection
	grafana # Metrics visualization
	loki # Log aggregation
	promtail # Log shipping
	prometheus-node-exporter # Node metrics
	cadvisor # Container metrics
	
	# Cloud & API Tools
	awscli2 # AWS command line
	azure-cli # Azure command line
	google-cloud-sdk # Google Cloud SDK
	doctl # DigitalOcean CLI
	linode-cli # Linode CLI
	vultr-cli # Vultr CLI
	
	# Network & Security Tools
	nmap # Network scanner
	wireshark-cli # Network analyzer
	tcpdump # Packet analyzer
	netcat # Network utility
	openssl # SSL/TLS toolkit
	httpie # HTTP client
	
	# --------------------------------------------------------------------------
	# |                        DevSecOps & Security                           |
	# --------------------------------------------------------------------------
	# Security Scanning
	trivy # Vulnerability scanner
	grype # Vulnerability scanner
	syft # Software composition analysis
	semgrep # Static analysis
	bandit # Python security linter
	pip-audit # Python dependency audit
	
	# Secrets Management
	vault # Secrets management
	sops # Secrets encryption
	age # File encryption
	gopass # Password manager
	pass # Password store
	keychain # SSH key management
	
	# Security Analysis
	nuclei # Vulnerability scanner
	subfinder # Subdomain discovery
	amass # Subdomain enumeration
	assetfinder # Asset discovery
	waybackurls # Wayback machine URLs
	gau # Get all URLs
	ffuf # Web fuzzer
	gobuster # Directory/file brute forcer
	dirb # Web content scanner
	nikto # Web vulnerability scanner
	
	# --------------------------------------------------------------------------
	# |                      Low-Level & Robotics                             |
	# --------------------------------------------------------------------------
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
	
	# --------------------------------------------------------------------------
	# |                        System & Performance                           |
	# --------------------------------------------------------------------------
	# System Monitoring
	iotop # I/O monitoring
	vnstat # Network traffic monitor
	perf # Performance profiler
	strace # System call tracer
	ltrace # Library call tracer
	
	# Process & Memory Analysis
	psmisc # Process utilities
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
	
	# --------------------------------------------------------------------------
	# |                        Development Utilities                           |
	# --------------------------------------------------------------------------
	
	
	
	
	# --------------------------------------------------------------------------
	# |                            TUI Applications                            |
	# --------------------------------------------------------------------------
	# Network Tools
	bandwhich # Network utilization
	slurm # Network monitor
	speedtest-cli # Internet speed test
	
	# Database Tools
	mycli # MySQL CLI
	pgcli # PostgreSQL CLI
	litecli # SQLite CLI
	usql # Universal SQL CLI
	
	

	# --------------------------------------------------------------------------
	# |                            System & Hardware                           |
	# --------------------------------------------------------------------------
	acpi # ACPI utilities
	btop # System monitor
	brightnessctl # Brightness control
	dysk # Disk usage analyzer
	gvfs # Virtual filesystem support
	kmon # Kernel monitor
	libgtop # System monitoring library
	nvtopPackages.intel # Intel GPU monitoring
	power-profiles-daemon # Power management daemon
	s-tui # System monitoring TUI
	upower # Power management daemon

	# --------------------------------------------------------------------------
	# |                               Wayland                                  |
	# --------------------------------------------------------------------------
	cliphist # Clipboard history
	grim # Screenshot tool
	grimblast # Grim screenshot utility with blast functionality
	hyprcursor # Hyprland cursor
	hypridle # Hyprland idle daemon
	hyprland # Wayland compositor
	hyprlock # Hyprland screen locker
	hyprpaper # Hyprland wallpaper daemon
	hyprpicker # Hyprland color picker
	hyprpanel # Hyprland panel
	hyprshot # Hyprland screenshot tool
	hyprsunset # Hyprland night light
	hyprutils # Hyprland utilities
	slurp # Screen area selection
	wl-clipboard # Wayland clipboard
	wl-clip-persist # Persistent clipboard
	wl-color-picker # Wayland color picker
	wofi # Application launcher
	wofi-emoji # Emoji picker


	# --------------------------------------------------------------------------
	# |                                Audio                                   |
	# --------------------------------------------------------------------------
	alsa-firmware # ALSA firmware
	alsa-tools # ALSA utilities
	cava # Audio visualizer
	pamixer # PulseAudio mixer
	pavucontrol # PulseAudio control
	pipewire # Audio server
	playerctl # Media player control
	wireplumber # PipeWire session manager

	# --------------------------------------------------------------------------
	# |                              Networking                                |
	# --------------------------------------------------------------------------
	bluez # Bluetooth stack
	bluez-tools # Bluetooth utilities
	iwd # Wireless daemon
	networkmanager # Network management daemon
	networkmanagerapplet # NetworkManager applet

	# --------------------------------------------------------------------------
	# |                             File Manager                               |
	# --------------------------------------------------------------------------
	xfce.thunar # File manager
	xfce.thunar-archive-plugin # Archive support
	xfce.thunar-volman # Volume management
	xfce.tumbler # Thumbnail generator

	# --------------------------------------------------------------------------
	# |                            Media & Documents                           |
	# --------------------------------------------------------------------------
	ffmpeg # Media converter
	imagemagick # Image manipulation
	imv # Image viewer
	mpv # Media player
	pandoc # Document converter
	poppler # PDF utilities
	resvg # SVG renderer
	vlc # Media player
	zathura # PDF viewer

	# --------------------------------------------------------------------------
	# |                           GUI Applications                             |
	# --------------------------------------------------------------------------
	# DEV (Development)
	code-cursor # VS Code fork


	# Notes
	joplin-desktop # Note-taking app
	notesnook # Note-taking app
	obsidian # Knowledge management

	# Anime & Manga
	ani-cli # Anime streaming CLI
	komikku # Manga reader

	# Privacy, Anonymity & OpSec (Operational Security)
	librewolf # Privacy-focused browser
	mullvad-browser # Privacy browser
	onionshare-gui # Secure file sharing
	tor # Anonymous network

	# ComSec (Secure Communication)
	session-desktop # Secure messaging
	simplex-chat-desktop # Secure chat

	# Security
	gpa # GNU Privacy Assistant
	keepassxc # Password manager
	picocrypt # File encryption

	# General Utilities & Social
	discord # Chat application
	hackgregator # RSS aggregator
	puffin # RSS reader
	spotify # Music streaming
	syncthing # File synchronization
	taskwarrior3 # Task management

	# --------------------------------------------------------------------------
	# |                               AI                                       |
	# --------------------------------------------------------------------------
	gemini-cli # Google Gemini CLI
	fabric-ai # AI framework

	# --------------------------------------------------------------------------
	# |                          Development & Libraries                        |
	# --------------------------------------------------------------------------
	dart-sass # Sass compiler
	gtksourceview3 # Text editor widget
	libsoup_3 # HTTP library

	# --------------------------------------------------------------------------
	# |                               Drivers                                  |
	# --------------------------------------------------------------------------
	intel-gpu-tools # Intel GPU utilities
	vulkan-tools # Vulkan utilities
  ];
}
