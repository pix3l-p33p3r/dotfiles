{
  description = "1337 cluster Home Manager for elel-yak (goinfre nix-user-chroot)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Mesa 26 rusticl needs DRM >=3.59 (kernel 6.11+). Cluster runs 5.15 —
    # pin 24.05 mesa.opencl so AMD RX 6500 + Intel UHD 770 both work under rusticl.
    nixpkgs-2405.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    antigravity.url = "github:Hy4ri/antigravity-flake";
    codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, nixpkgs-2405, home-manager, antigravity, codex-desktop-linux, nix-index-database, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs2405 = import nixpkgs-2405 {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations."elel-yak" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit antigravity codex-desktop-linux pkgs2405; };
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
