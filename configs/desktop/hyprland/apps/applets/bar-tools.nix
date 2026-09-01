# Bar helpers as store binaries — Wayle must not call ~/dotfiles/scripts.
{ pkgs }:

let
  inherit (pkgs) writeShellApplication;
in
rec {
  firewall-status = writeShellApplication {
    name = "firewall-status";
    runtimeInputs = [ pkgs.systemd ];
    text = ''
      if systemctl is-active --quiet nftables; then
        echo '{"alt":"on","status":""}'
      else
        echo '{"alt":"off","status":"!"}'
      fi
    '';
  };

  firewall-toggle = writeShellApplication {
    name = "firewall-toggle";
    runtimeInputs = [ pkgs.systemd pkgs.libnotify ];
    text = ''
      if systemctl is-active --quiet hotspot && systemctl is-active --quiet nftables; then
        notify-send -u critical -i security-low "Firewall" \
          "Cannot disable firewall while hotspot is active."
        exit 0
      fi
      if systemctl is-active --quiet nftables; then
        systemctl stop nftables
        notify-send -i security-low "Firewall" "Firewall OFF"
      else
        systemctl start nftables
        notify-send -i security-high "Firewall" "Firewall ON"
      fi
    '';
  };

  dns-status = writeShellApplication {
    name = "dns-status";
    runtimeInputs = [ pkgs.systemd pkgs.gnugrep pkgs.coreutils ];
    text = ''
      CURRENT=$(resolvectl dns 2>/dev/null | head -1)
      if echo "$CURRENT" | grep -qE "(extended|base|adblock|all)\.dns\.mullvad"; then
        echo '{"alt":"filter","status":""}'
      else
        echo '{"alt":"plain","status":"!"}'
      fi
    '';
  };

  dns-toggle = writeShellApplication {
    name = "dns-toggle";
    runtimeInputs = [ pkgs.systemd pkgs.libnotify pkgs.gnugrep pkgs.coreutils ];
    text = ''
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
        notify-send -i preferences-system-network "DNS" "Switched to filtered DNS"
      fi
    '';
  };

  hotspot-status = writeShellApplication {
    name = "hotspot-status";
    runtimeInputs = [ pkgs.systemd pkgs.hostapd pkgs.gnugrep pkgs.coreutils ];
    text = ''
      if systemctl is-active --quiet hotspot; then
        COUNT=$(hostapd_cli -p /run/hostapd -i ap0 all_sta 2>/dev/null \
          | grep -c '^..:..:..:..:..:..') || COUNT=0
        echo "{\"alt\":\"on\",\"status\":\"$COUNT\"}"
      else
        echo "{\"alt\":\"off\",\"status\":\"\"}"
      fi
    '';
  };

  hotspot-toggle = writeShellApplication {
    name = "hotspot-toggle";
    runtimeInputs = [ pkgs.systemd pkgs.libnotify pkgs.coreutils ];
    text = ''
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
      (sleep 3 && systemctl --user try-restart wayle.service) &
    '';
  };

  hotspot-manage = writeShellApplication {
    name = "hotspot-manage";
    runtimeInputs = [
      pkgs.systemd
      pkgs.hostapd
      pkgs.rofi
      pkgs.zenity
      pkgs.sops
      pkgs.libnotify
      pkgs.gawk
      pkgs.gnugrep
      pkgs.coreutils
    ];
    text = ''
      CTRL="/run/hostapd"
      IFACE="ap0"
      LEASE_FILE="/var/lib/dnsmasq/dnsmasq.leases"
      SOPS_FILE="''${HOME}/dotfiles/secrets/hosts/alucard.yaml"

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
            entries+="  Kick ''${mac} ''${ip:-(no IP)}\n"
          done <<< "$macs"
        else
          entries+="  No clients connected\n"
        fi
        entries+=" Change Password\n"
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
          if [ -n "$NEWPASS" ] && [ ''${#NEWPASS} -ge 8 ]; then
            if sops --set '["hotspot"]["wpa_passphrase"] "'"$NEWPASS"'"' "$SOPS_FILE"; then
              systemctl stop hotspot
              sleep 1
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
    '';
  };

  packages = [
    firewall-status
    firewall-toggle
    dns-status
    dns-toggle
    hotspot-status
    hotspot-toggle
    hotspot-manage
  ];
}
