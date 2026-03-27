{ pkgs, ... }:

{
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-strongswan
  ];

  environment.systemPackages = with pkgs; [
    strongswan
  ];

  # Allow IKE negotiation and NAT-T through the firewall
  networking.firewall.allowedUDPPorts = [ 500 4500 ];
}
