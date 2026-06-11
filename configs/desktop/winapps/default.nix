# WinApps — Perplexity Comet and other Windows apps over libvirt + FreeRDP.

{ config, lib, pkgs, inputs, ... }:

let
  winappsPkgs = inputs.winapps.packages.${pkgs.system};

  rdpPassHelper = pkgs.writeShellScriptBin "winapps-rdp-pass" ''
    set -euo pipefail
    secret="$HOME/.config/sops-secrets/winapps-rdp-password"
    conf="$HOME/.config/winapps/winapps.conf"

    if [[ -s "$secret" ]]; then
      ${pkgs.coreutils}/bin/cat "$secret"
      exit 0
    fi

    if [[ -f "$conf" ]]; then
      pass=$(${pkgs.gnugrep}/bin/grep -E '^RDP_PASS=' "$conf" | ${pkgs.gnused}/bin/sed 's/^RDP_PASS="\(.*\)"/\1/' || true)
      if [[ -n "$pass" ]]; then
        printf '%s' "$pass"
        exit 0
      fi
    fi

    ${pkgs.libnotify}/bin/notify-send -u critical "WinApps" "Set RDP_PASS in ~/.config/winapps/winapps.conf or add winapps/rdp_password to SOPS"
    exit 1
  '';
in
{
  home.packages = with pkgs; [
    winappsPkgs.winapps
    winappsPkgs.winapps-launcher
    freerdp
    virt-manager
    dialog
    netcat
    rdpPassHelper
  ];

  home.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

  # First deploy symlinks the template; activation replaces the symlink with a
  # writable file so RDP_PASS can be set by winapps-create-vm.sh.
  home.file.".config/winapps/winapps.conf" = {
    source = ./winapps.conf.template;
    force = false;
  };

  home.activation.winappsWritableConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    conf="$HOME/.config/winapps/winapps.conf"
    template=${./winapps.conf.template}
    if [ -L "$conf" ] || [ ! -e "$conf" ]; then
      $DRY_RUN_CMD mkdir -p "$(dirname "$conf")"
      $DRY_RUN_CMD cp "$template" "$conf"
      $DRY_RUN_CMD chmod 600 "$conf"
    fi
  '';

  # Optional: uncomment in homes/pixel-peeper/sops.nix after adding
  # winapps/rdp_password to secrets/users/pixel-peeper.yaml
}
