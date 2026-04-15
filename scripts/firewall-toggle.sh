#!/usr/bin/env bash
# Toggle nftables firewall on/off.
# Polkit allows pixel-peeper to manage nftables.service without sudo.

if systemctl is-active --quiet hotspot && systemctl is-active --quiet nftables; then
  notify-send -u critical -i security-low "Firewall" \
    "Cannot disable firewall while hotspot is active.\nNAT rules would be lost — clients lose internet."
  exit 0
fi

if systemctl is-active --quiet nftables; then
  systemctl stop nftables
  notify-send -i security-low "Firewall" "Firewall OFF"
else
  systemctl start nftables
  notify-send -i security-high "Firewall" "Firewall ON"
fi
