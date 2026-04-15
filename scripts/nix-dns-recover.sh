#!/usr/bin/env bash
# When Mullvad DoT (or uplink DNS) fails, nix cannot resolve cache.nixos.org and
# nixos-rebuild breaks. Run this once (needs sudo) to point systemd-resolved at
# public DoT resolvers, then retry rebuild. After a successful switch, dns.nix
# FallbackDNS keeps this from being a hard single point of failure.
set -euo pipefail

if getent hosts cache.nixos.org >/dev/null 2>&1; then
  echo "DNS OK — cache.nixos.org resolves."
  exit 0
fi

echo "DNS broken — temporarily using Cloudflare + Google DoT on Global (sudo)..."
sudo resolvectl dns Global \
  '1.1.1.1#cloudflare-dns.com' \
  '8.8.8.8#dns.google' \
  '1.0.0.1#cloudflare-dns.com' \
  '8.8.4.4#dns.google'
sudo resolvectl flush-caches

if ! getent hosts cache.nixos.org >/dev/null 2>&1; then
  echo "Still failing — check Wi-Fi/Ethernet, firewall, and time sync (DoT needs correct clock)." >&2
  exit 1
fi

echo "Recovered. Run: sudo nixos-rebuild switch --flake '.#alucard'"
