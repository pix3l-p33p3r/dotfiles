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
    data-root = "/var/lib/docker";

    # ── Network hardening ──
    # Bind published container ports to loopback only — explicit -p flags
    # like `-p 0.0.0.0:80:80` still work but unspecified hosts default to
    # 127.0.0.1 instead of 0.0.0.0, so a forgotten `-p 80:80` doesn't expose
    # the container to the campus WiFi.
    ip = "127.0.0.1";
    # iptables DNAT instead of docker-proxy: faster, fewer attack surfaces,
    # and doesn't break source IP visibility inside containers.
    userland-proxy = false;
    # Disable inter-container communication on the default bridge — containers
    # must explicitly join a user-defined network to talk to each other.
    icc = false;
    # no-new-privileges as default security-opt: containers can't gain elevated
    # privileges via setuid binaries (defense-in-depth).
    no-new-privileges = true;
  };
}
