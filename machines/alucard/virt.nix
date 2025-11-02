# Virtualization Configuration (QEMU/KVM)

{ config, pkgs, ... }:

{
  # Enable libvirt daemon for managing VMs
  virtualisation.libvirtd.enable = true;
}
