{ ... }:
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
      DNS = [
        "194.242.2.4#base.dns.mullvad.net"
        "2a07:e340::4#base.dns.mullvad.net"
      ];
      DNSOverTLS = "yes";
      DNSSEC = "no";
      Domains = [ "~." ];
      FallbackDNS = [
        "1.1.1.1#cloudflare-dns.com"
        "8.8.8.8#dns.google"
        "1.0.0.1#cloudflare-dns.com"
        "8.8.4.4#dns.google"
      ];
    };
  };

  # NixOS also sets this when resolved is enabled; kept explicit for clarity.
  networking.networkmanager.dns = "systemd-resolved";
}
