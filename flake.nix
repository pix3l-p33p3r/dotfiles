{
  description = "alucard — lean NixOS + HM + disko + lanzaboote";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, lanzaboote, sops-nix, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.alucard = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit self; };
      modules = [
        disko.nixosModules.disko
        lanzaboote.nixosModules.lanzaboote
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        ./hosts/alucard
      ];
    };
  };
}
