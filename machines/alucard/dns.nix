{ pkgs, ... }:
{
  # ───── System-wide DNS-over-TLS via Mullvad ─────
  # "extended" resolver: ads + trackers + malware + social media.
  # Avoids "base" which NXDOMAIN'd Google domains YouTube needs.
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
        "194.242.2.5#extended.dns.mullvad.net"
      ];
      DNSOverTLS = "yes";
      # DNSSEC + filtering DNS = broken: Mullvad returns modified responses
      # for blocked domains whose DNSSEC signatures then fail validation
      # (e.g. youtube-ui.l.google.com → "failed-auxiliary"). Verified that
      # a fresh resolved restart doesn't help — the failure is immediate.
      # DoT already authenticates the channel to Mullvad.
      DNSSEC = "no";
      Domains = [ "~." ];
      FallbackDNS = [
        "9.9.9.9#dns.quad9.net"
        "149.112.112.112#dns.quad9.net"
        "2620:fe::fe#dns.quad9.net"
        "45.91.92.121#dot.libredns.gr"
        "2a03:4000:4b:23e::1#dot.libredns.gr"
        # IPv6 Mullvad here too — only used when all primary IPv4 paths fail
        "2a07:e340::5#extended.dns.mullvad.net"
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
  #
  # Trigger on every event NM might fire that *could* re-push DNS — `up`,
  # `dhcp4-change`, `dhcp6-change` cover the normal flow.  `connectivity-change`
  # and `hostname` catch corner cases (campus captive portal redirects,
  # hostname events that re-run dhclient hooks).
  networking.networkmanager.dispatcherScripts = [{
    source = pkgs.writeText "10-clear-link-dns" ''
      case "$2" in
        up|dhcp4-change|dhcp6-change|connectivity-change|hostname)
          ${pkgs.systemd}/bin/resolvectl dns "$1" ""
          ${pkgs.systemd}/bin/resolvectl default-route "$1" no
          ;;
      esac
    '';
    type = "basic";
  }];

  # Belt-and-suspenders: after every boot AND after every nrs reload of
  # systemd-resolved, sweep all interfaces and clear their DNS / default-route.
  # The dispatcher only fires on connection events; if a connection is already
  # up when resolved or NM is reloaded (e.g. during nrs), DHCP-pushed DNS like
  # `8.8.8.8` from the campus router can sit sticky on Link 3 with
  # +DefaultRoute, leaking queries past Mullvad.
  systemd.services.clear-link-dns = {
    description = "Clear DHCP-pushed per-link DNS (force Global Mullvad)";
    after = [ "systemd-resolved.service" "NetworkManager.service" ];
    wants = [ "systemd-resolved.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };
    script = ''
      set -u
      for iface in $(${pkgs.iproute2}/bin/ip -o link show \
                     | ${pkgs.gawk}/bin/awk -F': ' '{print $2}' \
                     | ${pkgs.gnugrep}/bin/grep -vE '^(lo|ap0|docker.*|veth.*|virbr.*|br-.*)$'); do
        ${pkgs.systemd}/bin/resolvectl dns "$iface" ""           2>/dev/null || true
        ${pkgs.systemd}/bin/resolvectl default-route "$iface" no 2>/dev/null || true
      done
    '';
  };
}
