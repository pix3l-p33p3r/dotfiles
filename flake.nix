{
  description = "pixel-peeper flake on T";
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sherlock = {
      url = "github:Skxxtz/sherlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, catppuccin, home-manager, stylix, sherlock, ... }@inputs: {
    # ===== NixOS Configuration =====
    nixosConfigurations.pixel-peeper = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };  # Pass inputs BEFORE modules
      modules = [
        ./machines/pixel-peeper
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.pixel-peeper = {
            imports = [
              ./homes/pixel-peeper
              #catppuccin.homeManagerModules.catppuccin
              catppuccin.homeModules.catppuccin
            ];
          };
        }
      ];
    };
    
    # ===== Standalone Home Manager Configuration =====
    homeConfigurations."pixel-peeper@pixel-peeper" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ./homes/pixel-peeper
        #catppuccin.homeManagerModules.catppuccin
        catppuccin.homeModules.catppuccin
      ];
    };
  };
}
