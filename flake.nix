{
  description = "pixel-peeper flake on T";
  
  inputs = {
    # Pinned to the current nixos-unstable channel commit (Hydra-built/cached)
    # for reproducible fast rebuilds and to avoid source builds for insecure-flagged
    # packages like old librewolf. To bump: run
    #   curl -sL https://channels.nixos.org/nixos-unstable/git-revision
    # then update the rev here and `nix flake lock --update-input nixpkgs`.
    nixpkgs.url = "github:NixOS/nixpkgs/567a49d1913ce81ac6e9582e3553dd90a955875f";
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      # Don't follow our nixpkgs - let lanzaboote use its own tested version
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      # Don't follow our nixpkgs — sops-nix's Go vendor hash is computed
      # against its own tested nixpkgs; overriding causes hash mismatches.
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-catppuccin-plymouth = {
      url = "github:GGetsov/nixos-catppuccin-plymouth";
      flake = false;
    };
    nur = {
      # Nix User Repository — used for `pkgs.nur.repos.rycee.firefox-addons.*`
      # in configs/browsers/librewolf.nix and configs/browsers/firefox.nix.
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, catppuccin, lanzaboote, home-manager, stylix, zen-browser, sops-nix, nixos-catppuccin-plymouth, nur, winapps, ... }@inputs: let
    system = "x86_64-linux";
    # Single overlay list — shared by both NixOS and Home Manager so they
    # can never diverge.
    overlays = [
      # Until nixpkgs includes nixpkgs#503035 (cargo vendor path layout).
      (import ./overlays/stremio-linux-shell.nix)
      # Bump ani-cli to v4.12 (allanime AES-256-CTR fix) until nixpkgs
      # picks up the upstream release.  See pystardust/ani-cli#1650.
      (import ./overlays/ani-cli.nix)
      # Bump google-chrome to 148.0.7778.178 ahead of the nixos-unstable
      # channel.  Upstream landed nixpkgs@68ed617 on master 2026-05-19.
      (import ./overlays/google-chrome.nix)
    ];
    nixpkgsConfig = {
      allowUnfree = true;
      # No more permittedInsecurePackages for librewolf: we now use an official
      # prebuilt AppImage (not the nixpkgs source derivation that was flagged insecure).
    };
    pkgs = import nixpkgs {
      inherit system;
      config = nixpkgsConfig;
      overlays = overlays;
    };


  in {
    # ===== NixOS Configuration =====
    nixosConfigurations.alucard = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs self; };
      modules = [
        { nixpkgs.overlays = overlays; }
        { nixpkgs.config = nixpkgsConfig; }

        ./machines/alucard
        sops-nix.nixosModules.sops
        lanzaboote.nixosModules.lanzaboote
        catppuccin.nixosModules.catppuccin
      ];
    };
    
    # ===== Standalone Home Manager Configuration =====
    homeConfigurations."pixel-peeper@alucard" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs self; wallpaper = self + "/assets/wallpapers/alucard.jpg"; };
      modules = [
        ./homes/pixel-peeper
        catppuccin.homeModules.catppuccin
        inputs.zen-browser.homeModules.twilight
        sops-nix.homeManagerModules.sops
      ];
    };
  };
}
