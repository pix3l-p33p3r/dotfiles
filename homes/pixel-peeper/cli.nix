# Daily CLI as store binaries + nh. No ~/dotfiles/scripts wrappers.
{ pkgs, ... }:

let
  nix-clean = pkgs.writeShellApplication {
    name = "nix-clean";
    # Never put pkgs.sudo in runtimeInputs — it shadows /run/wrappers/bin/sudo
    # (setuid) with a store copy that cannot elevate.
    runtimeInputs = [ pkgs.nix ];
    text = ''
      PATH="/run/wrappers/bin:$PATH"
      HM_PROFILE="$HOME/.local/state/nix/profiles/home-manager"
      if [ -L "$HM_PROFILE" ]; then
        nix-env --profile "$HM_PROFILE" --delete-generations +2
      fi
      nix-collect-garbage -d
      sudo nix-collect-garbage -d
      sudo nix store optimise
      nix store optimise
    '';
  };

  secscan = pkgs.writeShellApplication {
    name = "secscan";
    runtimeInputs = [ pkgs.systemd pkgs.gnugrep pkgs.coreutils pkgs.gnused ];
    text = ''
      PATH="/run/wrappers/bin:$PATH"
      ${builtins.readFile ../../configs/security/secscan.sh}
    '';
  };

  hw-accel = pkgs.writeShellApplication {
    name = "hw-accel";
    runtimeInputs = [
      pkgs.libva-utils
      pkgs.vulkan-tools
      pkgs.intel-gpu-tools
      pkgs.clinfo
      pkgs.pciutils
      pkgs.libnotify
    ];
    text = builtins.readFile ../../configs/desktop/hw-accel.sh;
  };

  nix-dns-recover = pkgs.writeShellApplication {
    name = "nix-dns-recover";
    runtimeInputs = [ pkgs.systemd pkgs.coreutils ];
    text = ''
      PATH="/run/wrappers/bin:$PATH"
      if getent hosts cache.nixos.org >/dev/null 2>&1; then
        echo "DNS OK — cache.nixos.org resolves."
        exit 0
      fi
      sudo resolvectl dns Global \
        '1.1.1.1#cloudflare-dns.com' \
        '8.8.8.8#dns.google' \
        '1.0.0.1#cloudflare-dns.com' \
        '8.8.4.4#dns.google'
      sudo resolvectl flush-caches
      if ! getent hosts cache.nixos.org >/dev/null 2>&1; then
        echo "Still failing — check uplink, firewall, and clock." >&2
        exit 1
      fi
      echo "Recovered. Run: nh os switch"
    '';
  };
in
{
  programs.nh = {
    enable = true;
    flake = "/home/pixel-peeper/dotfiles";
    # GC stays in machines/alucard/maint.nix — do not enable programs.nh.clean.
  };

  home.packages = [
    nix-clean
    secscan
    hw-accel
    nix-dns-recover
  ];
}
