{ config, lib, pkgs, ... }:

{
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-strongswan
  ];

  environment.systemPackages = with pkgs; [
    strongswan
  ];

  # ───── strongswan — IKEv1 Aggressive + XAuth + Config Mode ─────
  # Protocol: IPsec IKEv1 Aggressive, PSK + XAuth, Config Mode IP assignment
  # Phase 1: AES256/SHA256/DH14, lifetime 86400s, DPD + NAT-T enabled
  # Phase 2: AES256/SHA256/DH14 (PFS), lifetime 43200s
  #
  # Connection parameters (gateway IP, XAuth identity) are injected at
  # activation time via sops.templates — never stored in plaintext.
  sops.templates."ipsec.conf" = {
    owner = "root";
    group = "root";
    mode  = "0600";
    content = ''
      config setup
          charondebug="ike 2, knl 1, cfg 1"
          uniqueids=no

      conn ACS-POC
          keyexchange=ikev1
          authby=xauthpsk
          aggressive=yes

          ike=aes256-sha256-modp2048!
          ikelifetime=86400s

          esp=aes256-sha256-modp2048!
          lifetime=43200s
          rekey=yes

          right=${config.sops.placeholder."vpn/gateway_ip"}
          rightid=%any
          rightsubnet=0.0.0.0/0

          left=%defaultroute
          leftid=%myid
          leftsourceip=%config

          dpdaction=restart
          dpddelay=30s
          dpdtimeout=120s

          type=tunnel
          auto=add

          xauth=client
          xauth_identity=${config.sops.placeholder."vpn/xauth_identity"}
    '';
  };

  environment.etc."ipsec.conf".source = config.sops.templates."ipsec.conf".path;

  services.strongswan = {
    enable  = true;
    secrets = [ config.sops.secrets."ipsec_secrets".path ];
  };

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
