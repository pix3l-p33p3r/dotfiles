{ config, pkgs, lib, ... }:

let
  startHotspot = pkgs.writeShellScript "start-hotspot" ''
    set -euo pipefail

    IW="${pkgs.iw}/bin/iw"
    AWK="${pkgs.gawk}/bin/awk"
    NMCLI="${pkgs.networkmanager}/bin/nmcli"
    CAT="${pkgs.coreutils}/bin/cat"
    INSTALL="${pkgs.coreutils}/bin/install"
    SLEEP="${pkgs.coreutils}/bin/sleep"
    MKDIR="${pkgs.coreutils}/bin/mkdir"

    is_dfs() {
      local ch=$1
      [ "$ch" -ge 52 ] && [ "$ch" -le 144 ]
    }

    INFO=$($IW dev wlp0s20f3 info)
    CHANNEL=$(echo "$INFO" | $AWK '/channel [0-9]/{print $2}')
    FREQ=$(echo    "$INFO" | $AWK '/channel [0-9]/{gsub(/[()]/,"",$3); print $3}')

    if [ -z "$CHANNEL" ] || [ -z "$FREQ" ]; then
      echo "ERROR: wlp0s20f3 has no channel — is WiFi connected?" >&2
      exit 1
    fi

    echo "STA is on channel $CHANNEL ($FREQ MHz)"

    if is_dfs "$CHANNEL"; then
      CONN=$($NMCLI -t -f GENERAL.CONNECTION device show wlp0s20f3 | $AWK -F: '{print $2}')
      echo "Channel $CHANNEL is DFS — locking '$CONN' to 2.4 GHz band..."

      $NMCLI con modify "$CONN" 802-11-wireless.band bg
      $NMCLI con up "$CONN" ifname wlp0s20f3 2>&1 || true
      $SLEEP 5

      INFO=$($IW dev wlp0s20f3 info)
      CHANNEL=$(echo "$INFO" | $AWK '/channel [0-9]/{print $2}')
      FREQ=$(echo    "$INFO" | $AWK '/channel [0-9]/{gsub(/[()]/,"",$3); print $3}')
      echo "Now on channel $CHANNEL ($FREQ MHz)"

      if is_dfs "$CHANNEL"; then
        echo "ERROR: Still on DFS channel $CHANNEL after band lock." >&2
        $NMCLI con modify "$CONN" 802-11-wireless.band ""
        exit 1
      fi
    fi

    if [ "$FREQ" -ge 5000 ]; then
      HW_MODE=a
    else
      HW_MODE=g
    fi

    WPA=$($CAT /run/secrets/hotspot/wpa_passphrase)

    $MKDIR -p /run/hostapd

    CONF=/run/hostapd-hotspot.conf
    $INSTALL -m 0600 /dev/null "$CONF"
    {
      echo "ctrl_interface=/run/hostapd"
      echo "ctrl_interface_group=users"
      echo "interface=ap0"
      echo "ssid=Alucard=pixel-peeper"
      echo "hw_mode=$HW_MODE"
      echo "channel=$CHANNEL"
      echo "country_code=MA"
      echo "ieee80211d=1"
      echo "ieee80211n=1"
      if [ "$HW_MODE" = "a" ]; then
        echo "ieee80211ac=1"
      fi
      echo "wmm_enabled=1"
      echo "wpa=2"
      echo "wpa_passphrase=$WPA"
      echo "wpa_key_mgmt=WPA-PSK"
      echo "rsn_pairwise=CCMP"
    } >> "$CONF"

    echo "Starting hostapd on ap0 — channel $CHANNEL ($FREQ MHz, hw_mode=$HW_MODE)"
    exec ${pkgs.hostapd}/bin/hostapd "$CONF"
  '';

  stopHotspot = pkgs.writeShellScript "stop-hotspot" ''
    NMCLI="${pkgs.networkmanager}/bin/nmcli"
    AWK="${pkgs.gawk}/bin/awk"
    RM="${pkgs.coreutils}/bin/rm"

    CONN=$($NMCLI -t -f GENERAL.CONNECTION device show wlp0s20f3 2>/dev/null | $AWK -F: '{print $2}') || true
    if [ -n "$CONN" ]; then
      $NMCLI con modify "$CONN" 802-11-wireless.band "" 2>/dev/null || true
    fi

    $RM -f /run/hostapd-hotspot.conf
  '';
in

{
  networking.networkmanager.unmanaged = [ "interface-name:ap0" ];
  networking.wireless.interfaces = [ "wlp0s20f3" ];

  systemd.services.wifi-ap-interface = {
    description = "Create ap0 virtual WiFi AP interface";
    after    = [ "sys-subsystem-net-devices-wlp0s20f3.device" ];
    wants    = [ "sys-subsystem-net-devices-wlp0s20f3.device" ];
    before   = [ "hotspot.service" "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "-${pkgs.iw}/bin/iw dev ap0 del";
      ExecStart    =  "${pkgs.iw}/bin/iw dev wlp0s20f3 interface add ap0 type __ap";
      ExecStop     =  "${pkgs.iw}/bin/iw dev ap0 del";
    };
  };

  networking.interfaces.ap0.ipv4.addresses = [{
    address = "192.168.50.1";
    prefixLength = 24;
  }];

  environment.systemPackages = [ pkgs.iw pkgs.hostapd pkgs.zenity ];

  systemd.services.hotspot = {
    description = "Wi-Fi hotspot (ap0) via hostapd";
    after  = [ "wifi-ap-interface.service" "sops-install-secrets.service"
               "network-addresses-ap0.service" ];
    wants  = [ "wifi-ap-interface.service" "dnsmasq.service" ];
    wantedBy = [];
    serviceConfig = {
      Type         = "simple";
      ExecStart    = startHotspot;
      ExecStopPost = stopHotspot;
      Restart      = "no";
    };
  };

  # Hotspot DNS only forwards to systemd-resolved; do not register dnsmasq as the system resolver or inject resolv-file (avoids "ignoring resolv-file ... no-resolv").
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      interface       = "ap0";
      bind-interfaces = true;
      no-resolv       = true;
      server          = [ "127.0.0.53" ];
      dhcp-range      = [ "192.168.50.10,192.168.50.100,12h" ];
      dhcp-option     = [ "option:router,192.168.50.1" ];
    };
  };
  systemd.services.dnsmasq.bindsTo  = [ "hotspot.service" ];
  systemd.services.dnsmasq.wantedBy = lib.mkForce [];
  systemd.services.dnsmasq.after    = lib.mkForce [ "hotspot.service" ];

  networking.nat = {
    enable             = true;
    internalInterfaces = [ "ap0" ];
    externalInterface  = "wlp0s20f3";
  };

  networking.firewall.interfaces.ap0 = {
    allowedUDPPorts = [ 53 67 ];
    allowedTCPPorts = [ 53 ];
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id === "org.freedesktop.systemd1.manage-units" &&
          subject.user === "pixel-peeper") {
        var unit = action.lookup("unit");
        if (unit === "hotspot.service" ||
            unit === "dnsmasq.service" ||
            unit === "nftables.service") {
          return polkit.Result.YES;
        }
      }
    });
  '';
}
