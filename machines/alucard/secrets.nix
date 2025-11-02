# SOPS secrets management configuration
{ config, pkgs, ... }:

{
  # Enable SOPS
  sops.defaultSopsFile = ./../../secrets/hosts/alucard.yaml;
  
  # Use SSH key from home directory for age key decryption
  # This allows automatic decryption during system rebuild
  sops.age.sshKeyPaths = [ "/home/pixel-peeper/.ssh/id_ed25519" ];
  
  # Age key file location
  sops.age.keyFile = "/home/pixel-peeper/.config/sops/age/keys.txt";
  
  # Example secret definitions
  # Uncomment and modify as needed
  
  # sops.secrets."ssh/host_key_ed25519" = {
  #   owner = "root";
  #   group = "systemd-network";
  #   mode = "0400";
  #   # path = config.services.openssh.hostKeys[0].path;
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
  
  # sops.secrets."database/postgresql_password" = {
  #   owner = "postgres";
  #   group = "postgres";
  #   mode = "0400";
  #   sopsFile = ./../../secrets/hosts/alucard.yaml;
  # };
}

