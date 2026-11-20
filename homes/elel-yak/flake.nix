{
  description = "1337 cluster Home Manager for elel-yak (goinfre nix-user-chroot)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    antigravity.url = "github:Hy4ri/antigravity-flake";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, home-manager, antigravity, nix-index-database, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations."elel-yak" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit antigravity; };
        modules = [
          ./home.nix
          nix-index-database.homeModules.nix-index
          { programs.nix-index-database.comma.enable = true; }
        ];
      };

      # Convenience: nix run .#hm -- switch --flake .#elel-yak
      packages.${system} = {
        hm = home-manager.packages.${system}.default;
        default = self.packages.${system}.hm;
      };
    };
}
