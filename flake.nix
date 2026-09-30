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
    nixos-hardware = {
      # T14s Gen 2i has no model-specific profile — import
      # lenovo-thinkpad-t14s and keep i915/PSR local. Their nixpkgs is
      # only for upstream tests; modules do not evaluate it.
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Google Antigravity suite (hub/agent app, IDE, CLI `agy`, Python SDK).
    # Keep its own nixpkgs — packages are mostly prebuilt binaries + FHS wrap.
    antigravity = {
      url = "github:Hy4ri/antigravity-flake";
    };
    # Unofficial ChatGPT / Codex desktop for Linux — wraps OpenAI's official
    # Linux .deb. Keep its own nixpkgs so the project cachix hits.
    codex-desktop-linux = {
      url = "github:ilysenko/codex-desktop-linux";
    };
  };
  
  outputs = { self, nixpkgs, catppuccin, lanzaboote, home-manager, stylix, zen-browser, sops-nix, nixos-catppuccin-plymouth, nur, winapps, nixos-hardware, antigravity, codex-desktop-linux, ... }@inputs: let
    system = "x86_64-linux";
    # Shared overlay list for NixOS and Home Manager. Keep empty unless a
    # local override is still ahead of the pinned nixos-unstable channel.
    overlays = [ ];
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
        inputs.codex-desktop-linux.homeManagerModules.default
        sops-nix.homeManagerModules.sops
      ];
    };

    # On-demand hardware scan. Do not commit the JSON (gitignore).
    #   sudo nix run .#facter -- -o /tmp/facter.json
    apps.${system}.facter = {
      type = "app";
      program = "${pkgs.nixos-facter}/bin/nixos-facter";
    };
  };
}
