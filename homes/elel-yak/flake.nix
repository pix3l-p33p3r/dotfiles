{
  description = "1337 cluster Home Manager for elel-yak (goinfre nix-user-chroot)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    antigravity.url = "github:Hy4ri/antigravity-flake";
  };

  outputs =
    { self, nixpkgs, home-manager, antigravity, ... }:
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
        modules = [ ./home.nix ];
      };

      # Convenience: nix run .#hm -- switch --flake .#elel-yak
      packages.${system} = {
        hm = home-manager.packages.${system}.default;
        default = self.packages.${system}.hm;
      };
    };
}
