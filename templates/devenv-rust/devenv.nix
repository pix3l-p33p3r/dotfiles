# Nix-scoped Rust — no rustup. Copy into a Cargo project, then:
#   devenv shell          # or: direnv allow
# When done:
#   toolchain-gc rust
{ pkgs, ... }:
{
  packages = with pkgs; [
    rustc
    cargo
    rustfmt
    clippy
    gcc
    pkg-config
  ];

  enterShell = ''
    echo "🦀 rustc $(rustc --version | awk '{print $2}') via nix (no rustup)"
    echo "   leave this dir, then: toolchain-gc rust"
  '';
}
