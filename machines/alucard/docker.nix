# Docker & Container Runtime Configuration

{ config, pkgs, lib, ... }:

{
  # Enable Docker daemon
  virtualisation.docker.enable = true;
  
  # Disable Docker daemon on boot for faster startup (~775ms savings)
  # Docker uses socket activation, so it will start automatically when first accessed
  virtualisation.docker.enableOnBoot = false;
  
  # Docker packages
  virtualisation.docker.package = pkgs.docker;
  
  # Enable Docker Compose
  virtualisation.docker.daemon.settings = {
    # Docker daemon configuration
    data-root = "/var/lib/docker";
  };
}
