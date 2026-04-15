# SOPS secrets management configuration
{ config, pkgs, ... }:

{
  # Enable SOPS
  sops.defaultSopsFile = ./../../secrets/hosts/alucard.yaml;
  
  # Age key for sops decryption. The SSH key is passphrase-protected so it
  # cannot be used as an age key source during unattended system activation.
  sops.age.keyFile = "/home/pixel-peeper/.config/sops/age/keys.txt";

  # ───── VPN ─────
  # Decrypted at activation time to /run/secrets/ipsec_secrets
  # Consumed by services.strongswan.secrets in vpn.nix
  sops.secrets."ipsec_secrets" = {
    owner = "root";
    group = "root";
    mode = "0600";
  };

  # VPN connection parameters — interpolated into ipsec.conf via sops.templates.
  # Root-owned: only consumed as sops.placeholder values, not read directly.
  sops.secrets."vpn/xauth_identity" = {
    owner = "root";
    group = "root";
    mode  = "0400";
  };

  sops.secrets."vpn/gateway_ip" = {
    owner = "root";
    group = "root";
    mode  = "0400";
  };

  # SSH target — read at runtime by acs-rofi and acs-work scripts.
  # Owned by pixel-peeper so user-space scripts can cat them.
  sops.secrets."vpn/ssh_host" = {
    owner = "pixel-peeper";
    group = "users";
    mode  = "0400";
  };

  sops.secrets."vpn/ssh_user" = {
    owner = "pixel-peeper";
    group = "users";
    mode  = "0400";
  };

  # ───── Hotspot ─────
  # WPA passphrase for the ap0 hostapd hotspot.
  # Add to secrets: sops secrets/hosts/alucard.yaml
  #   hotspot:
  #     wpa_passphrase: "yourpassword"
  sops.secrets."hotspot/wpa_passphrase" = {
    owner = "root";
    group = "root";
    mode  = "0600";
  };

  # ───── Inactive examples ─────

  # sops.secrets."ssh/host_key_ed25519" = {
  #   owner = "root";
  #   group = "systemd-network";
  #   mode = "0400";
  # };
  
  # sops.secrets."wireguard/private_key" = {
  #   owner = "root";
  #   group = "networkmanager";
  #   mode = "0400";
  # };
  
  # sops.secrets."api/github_token" = {
  #   owner = config.users.users.pixel-peeper.name;
  #   group = config.users.users.pixel-peeper.group;
  #   mode = "0400";
  # };
}

