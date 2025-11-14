# Virtualization Configuration (QEMU/KVM)

{ config, pkgs, lib, ... }:

{
  virtualisation.libvirtd.enable = true;
  
  # Don't start libvirtd on boot, use socket activation (libvirtd supports socket activation by default)
  systemd.services.libvirt-guests.wantedBy = lib.mkForce []; # Disable guest shutdown
}
