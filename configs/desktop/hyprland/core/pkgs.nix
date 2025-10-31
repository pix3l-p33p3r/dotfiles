{ pkgs, ... }:
{
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
		# |                            DEVELOPMENT TOOLS                            |
		# ============================================================================
		# Version Control
		git # Version control system
		git-lfs # Git large file storage
		git-crypt # Git encryption
		git-secrets # Git secrets scanner
		gh # GitHub CLI
		glab # GitLab CLI

		# Build Systems
		cmake # Cross-platform build system
		ninja # Build system
		meson # Build system
		pkg-config # Package configuration

		# Package Managers
		cargo # Rust package manager
		go # Go compiler
		nodejs # JavaScript runtime
		yarn # Node package manager
		pnpm # Node package manager
		pipx # Python package installer

		# Code Quality & Linting
		shellcheck # Shell script linter
		shfmt # Shell formatter
		hadolint # Dockerfile linter
		yamllint # YAML linter
		prettier # Code formatter
		prettierd # Prettier daemon
		black # Python formatter
		stylua # Lua formatter
		rustfmt # Rust formatter
		nixfmt # Nix formatter

		# Language Servers
		nixd # Nix language server
		pyright # Python language server
		eslint_d # JavaScript/TypeScript linter daemon
		pylint # Python linter
		rust-analyzer # Rust language server
		gopls # Go language server
		clang-tools # C/C++ language server
		typos-lsp # Typo checker language server
		bash-language-server # Bash language server
		svelte-language-server # Svelte language server
		typescript-language-server # TypeScript language server
		vscode-langservers-extracted # VS Code language servers
		emmet-ls # Emmet language server
		harper # Harper language server
		lua-language-server # Lua language server
		tailwindcss-language-server # Tailwind CSS language server
		yaml-language-server # YAML language server

		# Development Utilities
		ripgrep # Fast text search
		fd # Find replacement
		tree-sitter # Parser generator
		inotify-tools # File system monitoring
		gnumake # Build automation tool
		# haskellPackages.taskell # Haskell task management tool - marked as broken

		# ============================================================================
		# |                        CONTAINER & ORCHESTRATION                        |
		# ============================================================================
		# Container Runtime
		docker # Container runtime
		docker-compose # Multi-container orchestration
		buildah # Container image builder
		skopeo # Container image operations
		crane # Container registry operations

		# Kubernetes
		helm # Kubernetes package manager
		kustomize # Kubernetes configuration management
		minikube # Local Kubernetes
		kind # Kubernetes in Docker
		k3s # Lightweight Kubernetes
		k9s # Kubernetes TUI

		# ============================================================================
		# |                        INFRASTRUCTURE AS CODE                           |
		# ============================================================================
		terraform # Infrastructure provisioning
		terraform-ls # Terraform language server
		terragrunt # Terraform wrapper
		pulumi # Infrastructure as code
		ansible # Configuration management
		ansible-lint # Ansible linting

		# ============================================================================
		# |                            CI/CD & BUILD                               |
		# ============================================================================
		gitlab-runner # GitLab CI runner
		github-runner # GitHub Actions runner

		# ============================================================================
		# |                        MONITORING & OBSERVABILITY                       |
		# ============================================================================
		# Metrics & Logging
		prometheus # Metrics collection
		grafana # Metrics visualization
		loki # Log aggregation
		promtail # Log shipping
		prometheus-node-exporter # Node metrics
		cadvisor # Container metrics

		# ELK Stack
		tuistash # TUI for Logstash
		# kibana # ELK Stack UI - removed due to EOL Node.js dependency
		# logstash # ELK Stack log shipping - conflicts with elasticsearch
		elasticsearch # ELK Stack search and analytics

		# ============================================================================
		# |                            CLOUD & API TOOLS                           |
		# ============================================================================
		# Cloud Providers
		awscli2 # AWS command line
		azure-cli # Azure command line
		google-cloud-sdk # Google Cloud SDK
		amazon-ecs-cli # Amazon ECS CLI
		acr-cli # Azure Container Registry CLI

		# VPS Providers
		doctl # DigitalOcean CLI
		linode-cli # Linode CLI
		vultr-cli # Vultr CLI

		# ============================================================================
		# |                        NETWORK & SECURITY TOOLS                         |
		# ============================================================================
		# Network Analysis
		nmap # Network scanner
		wireshark-cli # Network analyzer
		tcpdump # Packet analyzer
		netcat # Network utility
		openssl # SSL/TLS toolkit

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
		gvfs # Virtual filesystem support
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
		fastfetch # System information
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

		# Git TUI Tools
		tig # Git repository browser
		git-interactive-rebase-tool # Interactive rebase
		gitui # Git TUI
		lazygit # Git TUI

		# Development TUI
		lazydocker # Docker TUI
		lazysql # SQL database TUI
		lazyjournal # Journal TUI
		lazyhetzner # Hetzner Cloud TUI
		stern # Kubernetes log tailing

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
		# |                            FILE MANAGEMENT                             |
		# ============================================================================
		xfce.thunar # File manager
		xfce.thunar-archive-plugin # Archive support
		xfce.thunar-volman # Volume management
		xfce.tumbler # Thumbnail generator
		papirus-folders # Papirus folder recoloring tool

		# ============================================================================
		# |                          MEDIA & DOCUMENTS                             |
		# ============================================================================
		# Media Tools
		ffmpeg # Media converter
		yt-dlp # YouTube downloader
		spotdl # Spotify downloader
		imagemagick # Image manipulation
		imv # Image viewer
		mpv # Media player
		vlc # Media player
		cava # Audio visualizer for terminal
		python3Packages.eyed3 # MP3 tagging for scripts

		# Music Players
		rmpc # Music player client (rust mpc)
		kew # TUI music player
		mpd # Music Player Daemon

		# Document Tools
		pandoc # Document converter
		poppler # PDF utilities
		resvg # SVG renderer
		zathura # PDF viewer

		# ============================================================================
		# |                           GUI APPLICATIONS                             |
		# ============================================================================
		# Development
		code-cursor # Code editor
		cursor-cli # Cursor CLI


		# Note Taking
		joplin-desktop # Note-taking app
		notesnook # Note-taking app
		obsidian # Knowledge management

		# Entertainment
		ani-cli # Anime streaming CLI
		komikku # Manga reader

		# Privacy & Security
		librewolf # Privacy-focused browser
		mullvad-browser # Privacy browser
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

		# ============================================================================
		# |                                 AI                                    |
		# ============================================================================
		gemini-cli # Google Gemini CLI
		fabric-ai # AI framework

		# ============================================================================
		# |                        DEVELOPMENT LIBRARIES                           |
		# ============================================================================
		dart-sass # Sass compiler
		gtksourceview3 # Text editor widget
		libsoup_3 # HTTP library

		# ============================================================================
		# |                               DRIVERS                                 |
		# ============================================================================
		intel-gpu-tools # Intel GPU utilities
		vulkan-tools # Vulkan utilities
	];
}