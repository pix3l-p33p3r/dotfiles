{ pkgs, lib, inputs, ... }:

let
  # Hardening prefs shared by both the clearnet `privacy` profile and the
  # `i2p` profile.  Centralized so changes apply uniformly.
  #
  # Combines:
  #   - my custom baseline (RFP, FPI, strict cookies, HTTPS-only)
  #   - the phytom2/Librefox-Hardening-Guide additions (sensors, normandy
  #     kill, captive portal off, referer trimming)
  hardenSettings = {
    # ── Network / DNS ─────────────────────────────────────────────────────
    "network.trr.mode"                              = 5;     # off; system DoT handles DNS
    "network.trr.confirmation_telemetry_enabled"    = false;
    "network.captive-portal-service.enabled"        = false; # no Mozilla pings
    "network.dns.disablePrefetch"                   = true;
    "network.prefetch-next"                         = false;
    "network.predictor.enabled"                     = false;
    "network.http.referer.XOriginPolicy"            = 2;     # Referer only on same hostname
    "network.http.referer.XOriginTrimmingPolicy"    = 2;     # strip path/query

    # ── WebRTC: KILLED ENTIRELY ───────────────────────────────────────────
    # If you need browser video/voice (Discord, Meet, Jitsi), flip:
    #   about:config -> media.peerconnection.enabled -> true
    # vesktop has its own embedded WebRTC and is unaffected by this.
    "media.peerconnection.enabled"                          = false;
    "media.peerconnection.ice.proxy_only_if_behind_proxy"   = true;

    # ── Sensors / device APIs (fingerprinting + tracking surface) ──────────
    "device.sensors.enabled"             = false;
    "device.sensors.motion.enabled"      = false;
    "device.sensors.orientation.enabled" = false;
    "dom.battery.enabled"                = false;
    "dom.gamepad.enabled"                = false;
    "dom.event.clipboardevents.enabled"  = false;

    # ── Geolocation ───────────────────────────────────────────────────────
    "geo.enabled"                  = false;
    "geo.prompt.open_system_prefs" = false;
    "geo.provider.network.url"     = "";

    # ── Tracking protection ───────────────────────────────────────────────
    "privacy.trackingprotection.enabled"                          = true;
    "privacy.trackingprotection.socialtracking.enabled"           = true;
    "privacy.trackingprotection.allow_list.convenience.enabled"   = false;
    "privacy.antitracking.isolateContentScriptResources"          = true;
    "privacy.resistFingerprinting"                                = true;
    "privacy.resistFingerprinting.letterboxing"                   = true;
    "privacy.firstparty.isolate"                                  = true;
    "privacy.purge_trackers.enabled"                              = true;
    "privacy.globalprivacycontrol.enabled"                        = true;

    # ── Cookies ───────────────────────────────────────────────────────────
    "network.cookie.cookieBehavior"  = 5;  # reject cross-site + social trackers
    "network.cookie.lifetimePolicy"  = 2;  # session-only

    # ── HTTPS ─────────────────────────────────────────────────────────────
    "dom.security.https_only_mode"             = true;
    "dom.security.https_only_mode_ever_enabled" = true;

    # ── Telemetry kill (LibreWolf has most off, make explicit) ────────────
    "datareporting.policy.dataSubmissionEnabled" = false;
    "nimbus.telemetry.targetingContextEnabled"   = false;
    "telemetry.fog.init_on_shutdown"             = false;
    "toolkit.telemetry.cachedProfileGroupID"     = "";
    "toolkit.telemetry.dap.helper.hpke"          = "";
    "toolkit.telemetry.dap.helper.url"           = "";
    "toolkit.telemetry.dap.leader.hpke"          = "";

    # ── Mozilla remote config kill ─────────────────────────────────────────
    "app.normandy.enabled" = false;
    "app.normandy.api_url" = "";

    # ── Misc ──────────────────────────────────────────────────────────────
    "beacon.enabled"                            = false;
    "browser.places.speculativeConnect.enabled" = false;
  };

  # I2P proxy settings, layered on top of `hardenSettings` for the i2p profile.
  i2pProxySettings = {
    "network.proxy.type"               = 1;            # manual proxy
    "network.proxy.http"               = "127.0.0.1";
    "network.proxy.http_port"          = 4444;
    "network.proxy.ssl"                = "127.0.0.1";
    "network.proxy.ssl_port"           = 4444;
    "network.proxy.share_proxy_settings" = true;
    "network.proxy.no_proxies_on"      = "";           # NO bypass
    "network.proxy.socks_remote_dns"   = true;         # DNS via proxy
    "network.dns.disabled"             = true;         # belt-and-suspenders
  };

  # Rofi-driven LibreWolf profile picker.  Same UX as `acs-rofi` in vpn.nix.
  librewolfPicker = pkgs.writeShellScriptBin "librewolf-picker" ''
    set -eu
    CHOICE=$(printf '  privacy\n󱄚  i2p' \
      | ${pkgs.rofi}/bin/rofi -dmenu -i -p 'LibreWolf' \
          -theme-str 'window {width: 360px;} listview {lines: 2;}')

    case "$CHOICE" in
      *privacy*) exec ${pkgs.librewolf}/bin/librewolf -P privacy "$@" ;;
      *i2p*)     exec ${pkgs.librewolf}/bin/librewolf -P i2p     "$@" ;;
    esac
  '';
in
{
  # Pull in NUR's Home Manager module so `pkgs.nur.repos.rycee.firefox-addons`
  # is populated with packaged Firefox / LibreWolf extensions.
  imports = [ inputs.nur.modules.homeManager.default ];

  # Tell stylix which LibreWolf profiles to theme (silences a startup warning).
  stylix.targets.librewolf.profileNames = [ "privacy" "i2p" ];

  programs.librewolf = {
    enable = true;

    # Default profile: clearnet, hardened.  System DoT (Mullvad) handles DNS.
    profiles."privacy" = {
      id = 0;
      isDefault = true;
      settings = hardenSettings;
      extensions = {
        # Acknowledge that we're managing extensions declaratively.
        force = true;
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          keepassxc-browser
          ublock-origin
          clearurls
          sponsorblock
          multi-account-containers
          darkreader
          noscript
        ];
      };
    };

    # I2P-only profile.  All traffic forced through the i2pd HTTP proxy at
    # 127.0.0.1:4444 (configured in machines/alucard/i2p.nix).  Cannot reach
    # clearnet — by design.  Launch with `librewolf -P i2p` or via the rofi
    # picker (see desktop entry below).
    profiles."i2p" = {
      id = 1;
      isDefault = false;
      settings = hardenSettings // i2pProxySettings;
      extensions = {
        force = true;
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          keepassxc-browser
          ublock-origin
          clearurls
          darkreader
          noscript
        ];
      };
    };
  };

  # Make the picker binary available on PATH so the .desktop entry resolves.
  home.packages = [ librewolfPicker ];

  # Override the upstream librewolf.desktop so Rofi drun launches the picker.
  # Home Manager writes ~/.local/share/applications/librewolf.desktop which
  # takes XDG precedence over the nixpkgs-shipped one.
  xdg.desktopEntries.librewolf = {
    name        = "LibreWolf";
    genericName = "Web Browser";
    comment     = "Privacy-hardened Firefox fork (profile picker)";
    exec        = "librewolf-picker %U";
    icon        = "librewolf";
    terminal    = false;
    categories  = [ "Network" "WebBrowser" ];
    mimeType = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "application/vnd.mozilla.xul+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };
}
