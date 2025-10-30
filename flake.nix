{
  description = "pixel-peeper flake on T";
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
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
  };
  
  outputs = { self, nixpkgs, catppuccin, flake-parts, home-manager, stylix, nur, zen-browser, ... }@inputs: {
    # Add wallpaper to the flake source
    wallpaper = self + "/assets/wallpapers/hellsing-4200x2366-19239.jpg";
    # ===== NixOS Configuration =====
    nixosConfigurations.pixel-peeper = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };  # Pass inputs BEFORE modules
      modules = [
        ./machines/pixel-peeper
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager
        {
          nix.settings.download-buffer-size = 104857600; # 100MB
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs; wallpaper = self + "/assets/wallpapers/hellsing-4200x2366-19239.jpg"; };
          home-manager.users.pixel-peeper = {
            imports = [
              ./homes/pixel-peeper
              #catppuccin.homeManagerModules.catppuccin
              catppuccin.homeModules.catppuccin
              inputs.zen-browser.homeModules.twilight
            ];
          };
        }
      ];
    };
    
    # ===== Standalone Home Manager Configuration =====
    homeConfigurations."pixel-peeper@pixel-peeper" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit inputs; wallpaper = self + "/assets/wallpapers/hellsing-4200x2366-19239.jpg"; };
      modules = [
        ./homes/pixel-peeper
        #catppuccin.homeManagerModules.catppuccin
        catppuccin.homeModules.catppuccin
        inputs.zen-browser.homeModules.twilight
      ];
    };
  };
}
