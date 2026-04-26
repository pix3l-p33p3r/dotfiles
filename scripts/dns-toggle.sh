#!/usr/bin/env bash
# Toggle between Mullvad DNS filtering modes at runtime via resolvectl.
# No rebuild or sudo needed — resolvectl uses D-Bus.
#
# Mullvad DNS tiers:
#   dns.mullvad.net       (194.242.2.2)  — unfiltered
#   adblock               (194.242.2.3)  — ads + trackers
#   base                  (194.242.2.4)  — ads + trackers + malware
#   extended              (194.242.2.5)  — base + social media (current)
#   family                (194.242.2.6)  — base + adult + gambling
#   all                   (194.242.2.9)  — everything

FILTER_V4="194.242.2.5#extended.dns.mullvad.net"
FILTER_V6="2a07:e340::5#extended.dns.mullvad.net"
PLAIN_V4="194.242.2.2#dns.mullvad.net"
PLAIN_V6="2a07:e340::2#dns.mullvad.net"

CURRENT=$(resolvectl dns 2>/dev/null | head -1)

if echo "$CURRENT" | grep -q "extended\.dns\.mullvad"; then
  resolvectl dns wlp0s20f3 "$PLAIN_V4" "$PLAIN_V6"
  notify-send -i preferences-system-network "DNS" "Switched to unfiltered DNS"
else
  resolvectl dns wlp0s20f3 "$FILTER_V4" "$FILTER_V6"
  notify-send -i preferences-system-network "DNS" "Switched to filtered DNS (ads + trackers + malware + social)"
fi
