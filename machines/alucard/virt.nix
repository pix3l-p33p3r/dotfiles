# Virtualization Configuration (QEMU/KVM)

{ config, pkgs, lib, ... }:

{
  virtualisation.libvirtd.enable = true;
  
  # Don't start libvirtd on boot, use socket activation (libvirtd supports socket activation by default)
  systemd.services.libvirt-guests.wantedBy = lib.mkForce []; # Disable guest shutdown

  # Upstream unit uses /usr/bin/sh, which doesn't exist on NixOS.
  # Force a Nix-safe ExecStart with runtimeShell and explicit binary paths.
  systemd.services.virt-secret-init-encryption.serviceConfig.ExecStart = lib.mkForce ''
    ${pkgs.runtimeShell} -c 'umask 0077 && (${pkgs.coreutils}/bin/dd if=/dev/random status=none bs=32 count=1 | ${pkgs.systemd}/bin/systemd-creds encrypt --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)'
  '';
}
