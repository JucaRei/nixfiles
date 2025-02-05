{ config, lib, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.hardware.networking;

  port = pkgs.writeShellScriptBin "port" ''
    usage() {
      printf 'usage: %s open|close tcp|udp|both PORT[:PORT]\n' "''${0##*/}" >&2
      exit "$@"
    }
    case $1 in
      -h) usage;;
      open) action=-I;;
      close) action=-D;;
      *) usage 1;;
    esac
    protocols=()
    [[ $2 == @(tcp|both) ]] && protocols+=(tcp)
    [[ $2 == @(udp|both) ]] && protocols+=(udp)
    (( ''${#protocols[@]} )) || usage 1
    port=$3
    [[ $port ]] || usage 1
    for proto in "''${protocols[@]}"; do
      for iptables in iptables ip6tables; do
        sudo "$iptables" "$action" nixos-fw -p "$proto" -m "$proto" --dport "$port" -j nixos-fw-accept
      done
    done
  '';

  exclusive-lan = pkgs.writeShellScriptBin "70-wifi-wired-exclusive" ''
    # From example 14:
    # https://manpages.ubuntu.com/manpages/focal/man7/nmcli-examples.7.html

    # This dispatcher script makes Wi-Fi mutually exclusive with wired networking. When a wired
    # interface is connected, Wi-Fi will be set to airplane mode (rfkilled). When the wired
    # interface is disconnected, Wi-Fi will be turned back on. Name this script e.g.
    # 70-wifi-wired-exclusive.sh and put it into /etc/NetworkManager/dispatcher.d/ directory.
    # See NetworkManager(8) manual page for more information about NetworkManager dispatcher
    # scripts.
    #!${pkgs.stdenv.shell}

    NMCLI=${pkgs.networkmanager}/bin/nmcli
    GREP=${pkgs.gnugrep}/bin/grep

    export LC_ALL=C

    enable_disable_wifi ()
    {
        result=$($NMCLI dev | $GREP "ethernet" | $GREP -w "connected")
        if [ -n "$result" ]; then
            $NMCLI radio wifi off
        else
            $NMCLI radio wifi on
        fi
    }

    if [ "$2" = "up" ]; then
        enable_disable_wifi
    fi

    if [ "$2" = "down" ]; then
        enable_disable_wifi
    fi
  '';
in
{
  options.${namespace}.hardware.networking = with types; {
    enable = mkBoolOpt false "Whether or not to enable networking support";
    manager = mkOpt' (types.nullOr (types.enum [ "network-manager" "wpa-supplicant" null ])) "network-manager";
    exclusive-locallan = mkOpt types.bool false "Whether or not to enable exclusive local LAN support";
    hosts = mkOpt attrs { } (mdDoc "An attribute set to merge with `networking.hosts`");
    powersave = mkOpt types.bool false "Whether or not to enable powersave mode";
    wakeOnLan = mkOpt types.bool false "Whether or not to enable Wake-on-LAN";
    custom-interface = mkOpt types.str null "A custom network interface to use";
  };

  config = mkIf cfg.enable {
    excalibur.user.extraGroups = mkIf (cfg.manager == "network-manager") [ "networkmanager" ];

    networking = {
      hosts = {
        "127.0.0.1" = [ "local.test" ] ++ (cfg.hosts."127.0.0.1" or [ ]);
      } // cfg.hosts;

      networkmanager = {
        enable = true;

        appendNameservers = [
          "1.1.1.2" # Cloudflare
          "1.0.0.1" # Cloudflare
          # "8.8.8.8" # Google
        ];

        # Prevent fragmentation and reassembly, which can improve network performance
        connectionConfig = {
          "ethernet.mtu" = 1462;
          "wifi.mtu" = 1462;
        };

        # Use AdGuard Public DNS with ad/tracker blocking
        #  - https://adguard-dns.io/en/public-dns.html
        # insertNameservers = [ "94.140.14.14" "94.140.15.15" ];

        dns = "systemd-resolved";


        wifi = mkIf (cfg.networkOpt == "network-manager") {
          backend = "iwd";
          powersave = mkDefault cfg.powersave;
          #macAddress = "random";
          #scanRandMacAddress = true;
        };

        # ethernet = {
        #   macAddress = "random";
        # };

        # plugins = with pkgs; [
        #   networkmanager-openvpn
        #   networkmanager-openconnect
        # ];

        dispatcherScripts = mkIf (cfg.exclusive-locallan == true) [
          {
            source = "${exclusive-lan}/bin/70-wifi-wired-exclusive";
          }
        ];
      };

      usePredictableInterfaceNames = mkDefault true;

      interfaces = {
        "${cfg.custom-interface}" = {
          wakeOnLan = mkIf (cfg.wakeOnLan == true) {
            enable = true;
            policy = [ "magic" ];
          };
        };
      };

      # Disabling DHCPCD in favor of NetworkManager
      dhcpcd.enable =
        if cfg.networkOpt == "network-manager" then false else true;
      timeServers = [ "time.google.com" "time.cloudflare.com" ];

      wireless = {
        enable = if cfg.manager == "network-manager" then true else false;
        iwd.package = pkgs.iwd;
      };
    };

    services = {
      resolved = {
        enable = if (cfg.networkOpt == "network-manager") then true else false;
        domains = [ "~." ];
        # dnsovertls = "true";
        # dnssec = "false";
      };

      # Modify autoconnect priority of the connection to my home network
      # modify-autoconnect-priority = {
      #   description = "Modify autoconnect priority of OPTUS_B27161 connection";
      #   script = ''
      #     nmcli connection modify OPTUS_B27161 connection.autoconnect-priority 1
      #   '';
      # };


      # tlp.settings = mkIf (cfg.wakeonlan) {
      #   # https://wiki.archlinux.org/title/Wake-on-LAN#Enable_WoL_in_TLP
      #   WOL_DISABLE = "N";
      # };
    };

    environment = {
      systemPackages = with pkgs; [
        whois
        socat
        nethogs
        dnsutils
        port
      ]
      ++ (optionals (cfg.wakeonlan) [
        # ethtool can be used to manually enable wakeOnLan, eg:
        #
        #    sudo ethtool -s enp7s0f1 wol g
        #
        # on verify its status:
        #
        #    sudo ethtool enp7s0f1 | grep Wake-on
        ethtool
      ]);
    };


    # Fixes an issue that normally causes nixos-rebuild to fail.
    # https://github.com/NixOS/nixpkgs/issues/180175
    systemd = {
      services = {
        NetworkManager-wait-online.enable = false;
        # NetworkManager-wait-online = {
        #   enable = mkForce false;
        #   serviceConfig = mkIf (cfg.networkOpt == "network-manager") {
        #     ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
        #   };
        # };

        disable-wifi-powersave = mkIf (config.networking.networkmanager.wifi.powersave)
          {
            wantedBy = [ "multi-user.target" ];
            path = [ pkgs.iw ];
            script = ''
              iw dev wlan0 set power_save off
            '';
          };
      };
    };
  };
}
