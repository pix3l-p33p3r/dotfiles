# WinApps — run Windows apps (e.g. Perplexity Comet) via libvirt + FreeRDP.
# See docs/WINAPPS.md for one-time Windows VM setup.

{ config, lib, ... }:

{
  # WinApps / libvirt expect the system URI (not session).
  environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";

  networking.firewall.trustedInterfaces = lib.mkAfter [ "virbr0" ];

  # Windows 11 needs a virtual TPM; OVMF is picked up by virt-manager from qemu.
  virtualisation.libvirtd.qemu.swtpm.enable = true;
}
