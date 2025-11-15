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
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sddm-catppuccin = {
      url = "github:khaneliman/catppuccin-sddm-corners";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, catppuccin, lanzaboote, home-manager, stylix, nur, zen-browser, sops-nix, sddm-catppuccin, ... }@inputs: {
    # ===== NixOS Configuration =====
    nixosConfigurations.alucard = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs self; };
      modules = [
        ./machines/alucard
        sops-nix.nixosModules.sops
        lanzaboote.nixosModules.lanzaboote
        catppuccin.nixosModules.catppuccin
      ];
    };
    
    # ===== Standalone Home Manager Configuration =====
    homeConfigurations."pixel-peeper@alucard" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit inputs self; wallpaper = self + "/assets/wallpapers/hellsing-4200x2366-19239.jpg"; };
      modules = [
        ./homes/pixel-peeper
        catppuccin.homeModules.catppuccin
        inputs.zen-browser.homeModules.twilight
        sops-nix.homeManagerModules.sops
      ];
    };
  };
}
