#!/usr/bin/env bash
# Toggle the hostapd Wi-Fi hotspot (ap0) on/off.
# systemctl is allowed without sudo via polkit (machines/alucard/hotspot.nix).

if systemctl is-active --quiet hotspot; then
  systemctl stop hotspot
  notify-send -i network-wireless-offline "Hotspot" "Hotspot turned OFF"
else
  systemctl start hotspot
  sleep 2
  if systemctl is-active --quiet hotspot; then
    notify-send -i network-wireless "Hotspot" "Hotspot ON  •  SSID: Alucard=pixel-peeper"
  else
    MSG=$(journalctl -u hotspot -n 5 --no-pager -o cat 2>/dev/null | tail -3)
    notify-send -u critical -i network-wireless-offline "Hotspot" "Failed to start.\n$MSG"
  fi
fi

# Restart hyprpanel after a delay so the WiFi menu re-binds to NM state.
# The DFS→2.4GHz channel switch can break AstalNetwork bindings.
(sleep 3 && systemctl --user restart hyprpanel) &
