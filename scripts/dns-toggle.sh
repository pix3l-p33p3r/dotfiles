#!/usr/bin/env bash
# Toggle between Mullvad DNS filtering modes at runtime via resolvectl.
# No rebuild or sudo needed — resolvectl uses D-Bus.

FILTER_V4="194.242.2.4#base.dns.mullvad.net"
FILTER_V6="2a07:e340::4#base.dns.mullvad.net"
PLAIN_V4="194.242.2.2#all.dns.mullvad.net"
PLAIN_V6="2a07:e340::2#all.dns.mullvad.net"

CURRENT=$(resolvectl dns 2>/dev/null | head -1)

if echo "$CURRENT" | grep -q "base.dns.mullvad"; then
  resolvectl dns wlp0s20f3 "$PLAIN_V4" "$PLAIN_V6"
  notify-send -i preferences-system-network "DNS" "Switched to plain DNS (no ad blocking)"
else
  resolvectl dns wlp0s20f3 "$FILTER_V4" "$FILTER_V6"
  notify-send -i preferences-system-network "DNS" "Switched to filtered DNS (ads + trackers blocked)"
fi
