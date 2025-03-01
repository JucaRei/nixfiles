{ hostname, hostid, lib, pkgs, config, username, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf mkDefault mdDoc optionals mkForce;
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

  cfg = config.core.network;
in
{
  options.core.network = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Wheater enable network for device";
    };
    networkOpt = mkOption {
      type = types.nullOr (types.enum [ "network-manager" "wpa-supplicant" null ]);
      default = null; # "network-manager";
      description = "Default network option.";
    };
    exclusive-locallan = mkOption {
      type = types.bool;
      default = false;
      description = "Wheter enable exclusive-lan.";
    };
    powersave = mkEnableOption "Wheter powersave on wifi." //
      {
        default = false;
        type = types.bool;
        description = "Enable powersave for wifi.";
      };
    wakeonlan = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Whether enable wakeOnLan";
    };

    custom-interface = mkOption {
      type = types.str;
      default = "";
      example = "eth0";
      description = "Desired interface.";
    };

  };

  config = mkIf cfg.enable {
    networking = {
      extraHosts = ''
        10.10.10.40   nitro
        10.10.10.100  Soyoz
        10.10.10.45   rocinante
        10.10.10.230  air
        10.10.10.200  DietPi
        192.168.122.* vm
        192.168.122.* scrubber
      '';

      # use network manager instead of wpa supplicant
      wireless = mkIf (cfg.networkOpt != "network-manager") {
        enable = true;
        # iwd = {
        #   enable = mkIf (cfg.networkOpt == "network-manager") true;
        #   package = pkgs.iwd;
        # };
      };
      # Disabling DHCPCD in favor of NetworkManager
      dhcpcd.enable = mkIf (cfg.networkOpt == "wpa-supplicant") true;
      timeServers = [ "time.google.com" "time.cloudflare.com" ];
      networkmanager = mkIf (cfg.networkOpt == "network-manager") {
        enable = true;
        appendNameservers = [
          "1.1.1.2" # Cloudflare
          "1.0.0.1" # Cloudflare
          # "8.8.8.8" # Google
          ## Quad9 v4
          # "9.9.9.9"
          # "149.112.112.112"
          ## Quad9 v6
          # "2620:fe::fe"
          # "2620:fe::9"
        ];
        dns = "systemd-resolved";

        # Prevent fragmentation and reassembly, which can improve network performance
        connectionConfig = {
          "ethernet.mtu" = 1462;
          "wifi.mtu" = 1462;
        };

        # Use AdGuard Public DNS with ad/tracker blocking
        #  - https://adguard-dns.io/en/public-dns.html
        # insertNameservers = [ "94.140.14.14" "94.140.15.15" ];

        wifi = {
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

      hostName = hostname;
      hostId = hostid;
      # usePredictableInterfaceNames = mkDefault false;

      interfaces = {
        "${cfg.custom-interface}" = {
          wakeOnLan = mkIf (cfg.wakeonlan == true) {
            enable = true;
            policy = [ "magic" ];
          };
        };
      };
    };
    services = {
      resolved = {
        enable = mkIf (cfg.networkOpt == "network-manager") true;
        domains = [ "~." ];
        # dnsovertls = "true";
        # dnsovertls = "opportunistic";
        # dnssec = "allow-downgrade";
        # dnssec = "false";
      };

      # Modify autoconnect priority of the connection to my home network
      # modify-autoconnect-priority = {
      #   description = "Modify autoconnect priority of OPTUS_B27161 connection";
      #   script = ''
      #     nmcli connection modify OPTUS_B27161 connection.autoconnect-priority 1
      #   '';
      # };

      tlp.settings = mkIf (cfg.wakeonlan) {
        # https://wiki.archlinux.org/title/Wake-on-LAN#Enable_WoL_in_TLP
        WOL_DISABLE = "N";
      };
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

    # https://github.com/NixOS/nixpkgs/issues/180175#issuecomment-1658731959
    systemd = {
      services = {
        # NetworkManager-wait-online = {
        #   serviceConfig = mkIf (cfg.networkOpt == "network-manager") {
        #     ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
        #   };
        # };

        # Stuck at system boot
        NetworkManager-wait-online.enable = mkForce false;
        systemd-networkd-wait-online.enable = mkForce false;
        systemd-networkd.stopIfChanged = mkForce false;
        systemd-resolved.stopIfChanged = mkForce false;

        disable-wifi-powersave = mkIf (cfg.powersave) {
          wantedBy = [ "multi-user.target" ];
          path = [ pkgs.iw ];
          script = ''
            iw dev wlan0 set power_save off
          '';
        }
        ;
      };

      extraConfig = "DefaultTimeoutStopSec=30s";
    };

    users.users.${username}.extraGroups = optionals config.networking.networkmanager.enable [ "networkmanager" ];
  };
}
