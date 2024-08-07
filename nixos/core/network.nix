{ hostname, hostid, lib, pkgs, config, ... }:
let

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
  networking = {
    extraHosts = ''
      192.168.1.35  nitro
      192.168.1.45  rocinante
      192.168.1.76  dongle
      192.168.1.228 rocinante
      192.168.1.184 soyo
      192.168.1.230 air
      192.168.1.200 DietPi
      192.168.122.* vm
      192.168.122.* scrubber
    '';

    # interfaces = {
    #   "enp7s0f1".wakeOnLan.enable = true;
    # };

    wireless.enable = false; # use network manager instead of wpa supplicanmt

    # Disabling DHCPCD in favor of NetworkManager
    dhcpcd.enable = false;
    timeServers = [
      "time.google.com"
      "time.cloudflare.com"
    ];
    networkmanager = lib.mkDefault {
      enable = true;
      appendNameservers = [
        "1.1.1.1" # Cloudflare
        "8.8.8.8" # Google
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
        powersave = false;
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

      dispatcherScripts = [
        {
          # source = ./nm-dispatcher-scripts/70-wifi-wired-exclusive.sh;
          source = "${exclusive-lan}/bin/70-wifi-wired-exclusive";
        }
      ];
    };
    wireless.iwd.package = pkgs.unstable.iwd;

    hostName = hostname;
    hostId = hostid;
    usePredictableInterfaceNames = true;
  };
  services.resolved = {
    enable = true;
  };

  environment = {
    systemPackages = with pkgs;[
      whois
      socat
      nethogs
      dnsutils
      port

      # ethtool can be used to manually enable wakeOnLan, eg:
      #
      #    sudo ethtool -s enp7s0f1 wol g
      #
      # on verify its status:
      #
      #    sudo ethtool enp7s0f1 | grep Wake-on
      ethtool
    ];
  };



  # https://github.com/NixOS/nixpkgs/issues/180175#issuecomment-1658731959
  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
    };
  };
}
