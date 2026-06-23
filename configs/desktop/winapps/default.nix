# WinApps — Perplexity Comet and other Windows apps over libvirt + FreeRDP.

{ config, lib, pkgs, inputs, ... }:

let
  winappsPkgs = inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system};

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

  # winapps.conf must be a writable real file (RDP_PASS is set by
  # winapps-create-vm.sh), so it is NOT managed via home.file (which would
  # symlink it read-only into the store). The activation below seeds it from the
  # template on first deploy and leaves user edits untouched afterwards.
  home.activation.winappsWritableConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    conf="$HOME/.config/winapps/winapps.conf"
    template=${./winapps.conf.template}
    # Only seed when missing or still a (possibly stale) symlink into the store.
    # --remove-destination drops the symlink first so cp never sees src == dest.
    if [ -L "$conf" ] || [ ! -e "$conf" ]; then
      $DRY_RUN_CMD mkdir -p "$(dirname "$conf")"
      $DRY_RUN_CMD cp --remove-destination "$template" "$conf"
      $DRY_RUN_CMD chmod 600 "$conf"
    fi
  '';

  # Optional: uncomment in homes/pixel-peeper/sops.nix after adding
  # winapps/rdp_password to secrets/users/pixel-peeper.yaml
}
