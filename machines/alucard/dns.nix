{ pkgs, ... }:
{
  # ───── System-wide DNS-over-TLS via Mullvad ─────
  # Uses the "base" resolver: blocks ads, trackers, and malware.
  # Primary: Mullvad. Fallback: public DoT (still TLS, not plaintext) so a Mullvad
  # blip or captive-portal phase does not leave resolution entirely dead (nix/store
  # downloads need working DNS).
  #
  # DNS servers live under settings.Resolve (nixpkgs removed the old
  # services.resolved.dns top-level option).
  services.resolved = {
    enable = true;
    settings.Resolve = {
      # IPv4-only primary DNS. Many networks (campus WiFi, mobile hotspots,
      # captive portals) are IPv4-only — listing IPv6 DoT servers as primary
      # causes 5-10s "network unreachable" timeouts per query before falling
      # back to IPv4. The IPv6 endpoints below in FallbackDNS still cover
      # dual-stack networks if all IPv4 paths fail.
      DNS = [
        "194.242.2.4#base.dns.mullvad.net"
      ];
      DNSOverTLS = "yes";
      # allow-downgrade: validate DNSSEC where signatures exist (most TLDs)
      # without hard-failing on unsigned zones. Hard "yes" would break
      # captive-portal probing and any zone without DS records.
      DNSSEC = "allow-downgrade";
      Domains = [ "~." ];
      FallbackDNS = [
        "9.9.9.9#dns.quad9.net"
        "149.112.112.112#dns.quad9.net"
        "2620:fe::fe#dns.quad9.net"
        "45.91.92.121#dot.libredns.gr"
        "2a03:4000:4b:23e::1#dot.libredns.gr"
        # IPv6 Mullvad here too — only used when all primary IPv4 paths fail
        "2a07:e340::4#base.dns.mullvad.net"
      ];
      # Disable link-local name resolution protocols. On a campus / shared
      # network these broadcast our hostname (mDNS) and let attackers respond
      # to name queries (LLMNR poisoning / Responder attacks).
      LLMNR = "no";
      MulticastDNS = "no";
    };
  };

  # NixOS also sets this when resolved is enabled; kept explicit for clarity.
  networking.networkmanager.dns = "systemd-resolved";

  # NM pushes DHCP-received DNS onto the per-link resolver (wlp0s20f3) with
  # DefaultRoute=yes, which overrides the global Mullvad DoT config above.
  # This dispatcher clears per-link DNS after every connect/DHCP change so all
  # queries route through the global resolver exclusively.
  networking.networkmanager.dispatcherScripts = [{
    source = pkgs.writeText "10-clear-link-dns" ''
      case "$2" in
        up|dhcp4-change|dhcp6-change)
          ${pkgs.systemd}/bin/resolvectl dns "$1" ""
          ${pkgs.systemd}/bin/resolvectl default-route "$1" no
          ;;
      esac
    '';
    type = "basic";
  }];
}
