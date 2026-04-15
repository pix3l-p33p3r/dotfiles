#!/usr/bin/env bash
# Polled by hyprpanel custom bar module every 3s.
# Outputs JSON for icon switching and client count label.
if systemctl is-active --quiet hotspot; then
  COUNT=$(hostapd_cli -p /run/hostapd -i ap0 all_sta 2>/dev/null \
    | grep -c '^..:..:..:..:..:..') || COUNT=0
  echo "{\"alt\":\"on\",\"status\":\"$COUNT\"}"
else
  echo "{\"alt\":\"off\",\"status\":\"\"}"
fi
