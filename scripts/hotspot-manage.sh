#!/usr/bin/env bash
# Right-click rofi menu for hotspot client management.
# Requires: hostapd_cli, rofi, zenity, sops

CTRL="/run/hostapd"
IFACE="ap0"
LEASE_FILE="/var/lib/dnsmasq/dnsmasq.leases"
SOPS_FILE="$HOME/dotfiles/secrets/hosts/alucard.yaml"

if ! systemctl is-active --quiet hotspot; then
  notify-send -i network-wireless-offline "Hotspot" "Hotspot is not running"
  exit 0
fi

get_ip_for_mac() {
  local mac="$1"
  if [ -f "$LEASE_FILE" ]; then
    awk -v m="$mac" 'tolower($2)==tolower(m){print $3}' "$LEASE_FILE"
  fi
}

build_menu() {
  local entries=""
  local macs
  macs=$(hostapd_cli -p "$CTRL" -i "$IFACE" all_sta 2>/dev/null \
    | grep -oE '^[0-9a-fA-F:]{17}')

  if [ -n "$macs" ]; then
    while IFS= read -r mac; do
      ip=$(get_ip_for_mac "$mac")
      entries+="  Kick ${mac} ${ip:-(no IP)}\n"
    done <<< "$macs"
  else
    entries+="  No clients connected\n"
  fi

  entries+="󰌆  Change Password\n"
  entries+="  Stop Hotspot"

  echo -e "$entries"
}

CHOICE=$(build_menu | rofi -dmenu -i -p "Hotspot" -theme-str 'window {width: 400px;}')

case "$CHOICE" in
  *"Kick "*)
    MAC=$(echo "$CHOICE" | awk '{print $3}')
    hostapd_cli -p "$CTRL" -i "$IFACE" deauthenticate "$MAC" 2>/dev/null
    notify-send -i network-wireless "Hotspot" "Kicked $MAC"
    ;;
  *"Change Password"*)
    NEWPASS=$(zenity --password --title="New Hotspot Password" 2>/dev/null)
    if [ -n "$NEWPASS" ] && [ ${#NEWPASS} -ge 8 ]; then
      sops --set '["hotspot"]["wpa_passphrase"] "'"$NEWPASS"'"' "$SOPS_FILE" 2>/dev/null
      if [ $? -eq 0 ]; then
        systemctl stop hotspot
        sleep 1
        sudo sops-install-secrets 2>/dev/null || true
        systemctl start hotspot
        notify-send -i network-wireless "Hotspot" "Password changed & hotspot restarted"
      else
        notify-send -u critical "Hotspot" "Failed to update sops secret"
      fi
    elif [ -n "$NEWPASS" ]; then
      notify-send -u critical "Hotspot" "Password must be at least 8 characters"
    fi
    ;;
  *"Stop Hotspot"*)
    systemctl stop hotspot
    notify-send -i network-wireless-offline "Hotspot" "Hotspot stopped"
    ;;
esac
