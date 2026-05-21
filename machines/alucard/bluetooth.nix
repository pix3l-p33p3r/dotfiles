{ pkgs, ... }:

{
  # ───── Bluetooth ─────
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  # services.blueman.enable is disabled to drop the always-running tray
  # applet (~85 MB across blueman-applet + blueman-tray). BT itself works
  # via the bluez stack. For pairing/UI on demand:
  #   - `bluetui`         — TUI (already in pkgs)
  #   - `bluetoothctl`    — CLI (from bluez-tools)
  #   - `blueman-manager` — GUI; launchable since blueman is in systemPackages below
  services.blueman.enable = false;

  environment.systemPackages = [ pkgs.blueman ];
}
