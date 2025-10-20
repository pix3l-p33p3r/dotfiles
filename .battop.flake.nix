{
  description = "pixel-peeper flake on T";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    # ===== Battop Overlay =====
    #overlays.battop = final: prev: {
    #  battop = final.rustPlatform.buildRustPackage rec {
    #    pname = "battop";
    #    version = "0.2.4";

    #    src = final.fetchFromGitHub {
    #      owner = "svartalf";
    #      repo = "rust-battop";
    #      rev = "v0.2.4";
    #      sha256 = "sha256-000000000000000000000000000000000000000000="; # Replace with correct source hash if needed
    #    };

    #    cargoLock = ./Cargo.lock;  # Use local Cargo.lock file for dependencies resolution

    #    meta = with final.lib; {
    #      description = "TUI battery monitor similar to htop/btop";
    #      license = licenses.mit;
    #      platforms = platforms.linux;
    #      maintainers = with maintainers; [ ];
    #    };
    #  };
    #};

    # ===== NixOS Configuration =====
    nixosConfigurations.pixel-peeper = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ self.overlays.battop ];
        })
        ./machines/pixel-peeper
      ];
    };

    # ===== Home Manager Configuration =====
    homeConfigurations."pixel-peeper@pixel-peeper" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "x86_64-linux"; overlays = [ self.overlays.battop ]; };
      modules = [ ./homes/pixel-peeper ];
      extraSpecialArgs = {
        inherit inputs;
      };
    };
  };
}

