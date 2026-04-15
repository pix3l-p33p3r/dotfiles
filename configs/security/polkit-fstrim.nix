{ pkgs, ... }:
{
  # Passwordless fstrim — used by Thunar's "Secure Delete" custom action to
  # immediately tell the NVMe to wipe freed blocks after rm.
  security.sudo.extraRules = [{
    users    = [ "pixel-peeper" ];
    commands = [
      { command = "${pkgs.util-linux}/bin/fstrim"; options = [ "NOPASSWD" ]; }
    ];
  }];
}
