{
  description = "pixel-peeper flake on T";
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix";
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
    nur = {
      url = "github:nix-community/NUR";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-catppuccin-plymouth = {
      url = "github:GGetsov/nixos-catppuccin-plymouth";
      flake = false;
    };
  };
  
  outputs = { self, nixpkgs, catppuccin, lanzaboote, home-manager, stylix, nur, zen-browser, sops-nix, nixos-catppuccin-plymouth, ... }@inputs: let
    system = "x86_64-linux";
    # Until nixpkgs includes nixpkgs#503035 (cargo vendor path layout).
    pkgs = nixpkgs.legacyPackages.${system}.extend (import ./overlays/stremio-linux-shell.nix);
  in {
    # ===== NixOS Configuration =====
    nixosConfigurations.alucard = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs self; };
      modules = [
        { nixpkgs.overlays = [ (import ./overlays/stremio-linux-shell.nix) ]; }
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
