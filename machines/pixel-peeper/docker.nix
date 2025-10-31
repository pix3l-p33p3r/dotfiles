# Docker & Container Runtime Configuration

{ config, pkgs, ... }:

{
  # Enable Docker daemon
  virtualisation.docker.enable = true;
  
  # Enable Docker daemon on boot
  virtualisation.docker.enableOnBoot = true;
  
  # Docker packages
  virtualisation.docker.package = pkgs.docker;
  
  # Enable Docker Compose
  virtualisation.docker.daemon.settings = {
    # Docker daemon configuration
    data-root = "/var/lib/docker";
  };
}
