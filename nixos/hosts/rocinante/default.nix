{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkForce;

  # Helper: verifica se há alguma interface Ethernet ativa (cabo conectado)
  hasActiveEthernet = pkgs.writeShellScript "has-active-ethernet" ''
    for dev in /sys/class/net/*; do
      name="''${dev##*/}"
      [ -d "$dev/wireless" ] && continue
      [ -e "$dev/device" ] || continue
      [ "$(cat "$dev/carrier" 2>/dev/null)" = "1" ] && exit 0
    done
    exit 1
  '';
in
{
  imports = [
    ./filesystem.nix
    ./disko-legacy.nix
    ./hardware-macbook.nix
  ];

  config = {
    services = {
      samba-wsdd = {
        enable = true;
        openFirewall = true;
      };

      gvfs.enable = true;

      avahi = {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          addresses = true;
          workstation = true;
        };
      };

      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true;
          KbdInteractiveAuthentication = true;
          PermitRootLogin = lib.mkDefault "no";
        };
        startWhenNeeded = true;
      };
    };

    networking = {
      hostName = "rocinante";
      search = [ "home.lan" ];
      nameservers = [
        "10.10.10.25"
        "10.10.10.26"
        "1.1.1.1"
        "8.8.8.8"
      ];

      resolvconf.extraConfig = ''
        options timeout:1 attempts:2 rotate
      '';

      firewall = {
        enable = true;
        allowPing = true;
        allowedUDPPorts = [
          5353
          3702
        ];
        allowedTCPPorts = [
          5353
          3702
        ];
      };

      networkmanager = {
        enable = true;
        wifi = {
          scanRandMacAddress = false;
          powersave = false;
          macAddress = "preserve";
        };
        settings = {
          connection = {
            "wifi-sec.pmf" = 1;
            "802-11-wireless-security.pmf" = 1;
            "802-11-wireless.mtu" = 1460;
          };
        };
        dispatcherScripts = [
          {
            source = pkgs.writeShellScript "wifi-wired-autoswitch" ''
              export PATH="${pkgs.networkmanager}/bin:$PATH"

              IFACE="$1"
              ACTION="$2"

              [ -z "$IFACE" ] || [ "$IFACE" = "lo" ] && exit 0
              [ -d "/sys/class/net/$IFACE/wireless" ] && exit 0
              [ -e "/sys/class/net/$IFACE/device" ] || exit 0

              case "$ACTION" in
                up)
                  nmcli radio wifi off
                  ;;
                down|post-down)
                  ${hasActiveEthernet} || nmcli radio wifi on
                  ;;
              esac
            '';
            type = "basic";
          }
        ];
      };
    };

    systemd.services.wifi-wired-autoswitch = {
      description = "Sincroniza rádio Wi-Fi com conexão cabeada no boot";
      after = [ "NetworkManager.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "wifi-wired-boot-sync" ''
          export PATH="${pkgs.networkmanager}/bin:$PATH"
          sleep 1
          if ${hasActiveEthernet}; then
            nmcli radio wifi off
          else
            nmcli radio wifi on
          fi
        '';
      };
    };

    environment = {
      systemPackages = with pkgs; [
        libva-utils
        vdpauinfo
        mesa-demos
        lm_sensors
        gptfdisk
        cifs-utils
        samba
      ];

      etc."samba/smb.conf".text = ''
        [global]
        workgroup = WORKGROUP
        client min protocol = NT1
        client max protocol = SMB3
        client ipc min protocol = NT1
        client ipc max protocol = SMB3
        client lanman auth = no
        client ntlmv2 auth = yes
        client use spnego = yes
        client signing = auto
      '';
    };

    specialisation = {
      nvidia = {
        inheritParentConfig = true;
        configuration = {
          system.nixos.tags = [ "nvidia-kernel-6.6" ];
          boot = {
            kernelPackages = mkForce pkgs.linuxPackages_6_6;
            kernelParams = mkForce [
              "zswap.enabled=0"
              "mitigations=off"
              "nowatchdog"
              "nouveau.modeset=0"
              "transparent_hugepage=madvise"
              "elevator=bfq"
              "splash"
              "quiet"
              "fbcon=nodefer"
              "nomodeset"
            ];
          };
          hardware.graphics.cards.gpu = mkForce "nvidia-legacy";

          home-manager.users.juca = {
            desktop.dwm.quickshell = {
              qsgBackend = mkForce "software";
              glIntegration = mkForce "none";
            };
            home.sessionVariables = {
              GPU_DRIVER_PROFILE = mkForce "nvidia-legacy";
            };
          };
        };
      };
    };
  };
}
