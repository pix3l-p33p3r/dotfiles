{ config, lib, pkgs, ... }:

{
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-strongswan
  ];

  environment.systemPackages = with pkgs; [
    strongswan
  ];

  # IKE (500), NAT-T (4500), and ESP (proto 50) for the IPsec data plane
  networking.firewall = lib.mkMerge [
    {
      allowedUDPPorts = [ 500 4500 ];
    }
    (lib.mkIf (config.networking.firewall.backend == "nftables") {
      extraInputRules = ''
        meta nfproto ipv4 ip protocol esp accept comment "IPsec ESP"
        meta nfproto ipv6 ip6 nexthdr esp accept comment "IPsec ESP IPv6"
      '';
    })
    (lib.mkIf (config.networking.firewall.backend == "iptables") {
      extraCommands = ''
        ip46tables -A nixos-fw -p esp -j nixos-fw-accept
      '';
    })
  ];
}
