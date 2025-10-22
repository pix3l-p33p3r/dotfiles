{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "battop";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "svartalf";
    repo = "rust-battop";
    rev = "master";
    sha256 = "sha256-000000000000000000000000000000000000000000="; # Use "nix flake check" to get the hash
  };

  cargoSha256 = "sha256-000000000000000000000000000000000000000000=";
  meta = with lib; {
    description = "TUI battery monitor";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}

