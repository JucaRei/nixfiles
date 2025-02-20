{ config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.environment.gnome;
  gdmHome = config.users.users.gdm.home;
in
{
  options.${namespace}.desktop.environment.gnome = with types; {
    enable = mkBoolOpt false "Whether or not to use Gnome as the desktop environment.";
    wayland = mkBoolOpt false "Whether or not to use Wayland.";
    suspend = mkBoolOpt true "Whether or not to suspend the machine after inactivity.";
    monitors = mkOpt (nullOr path) null "The monitors.xml file to create.";
    extensions = mkOpt (listOf package) [ ] "Extra Gnome extensions to install.";
  };

  config = mkIf cfg.enable {

    ${namespace} = {
      system.xkb.enable = true;

      desktop = {
        display-manager = {
          gdm = {
            enable = true;
            autoSuspend = true;
            defaultSession = "gnome";
            monitors = null;
            wayland = false;
          };
        };
      };

      programs.graphical = {
        # desktop-environment.gnome
      };
    };

    environment = {
      systemPackages =
        with pkgs;
        [
          (hiPrio "${namespace}".xdg-open-with-portal)
          blackbox-terminal
        ]
        ++ defaultExtensions
        ++ cfg.extensions;

      gnome.excludePackages = with pkgs // pkgs.gnome; [
        geary
        gnome-font-viewer
        gnome-maps
        baobab
        # gnome-text-editor
        gnome-tour
        gnome-user-docs
        geary
        gnome-system-monitor
        epiphany
        gnome-music
        totem
        gnome-console
        gnome-terminal

        evince
        simple-scan
      ];
    };

    systemd = {
      tmpfiles.rules =
        [ "d ${gdmHome}/.config 0711 gdm gdm" ]
        ++ (
          # "./monitors.xml" comes from ~/.config/monitors.xml when GNOME
          # display information is updated.
          lib.optional (cfg.monitors != null) "L+ ${gdmHome}/.config/monitors.xml - - - - ${cfg.monitors}"
        );

      services.excalibur-user-icon = {
        before = [ "display-manager.service" ];
        wantedBy = [ "display-manager.service" ];

        serviceConfig = {
          Type = "simple";
          User = "root";
          Group = "root";
        };

        script = ''
          config_file=/var/lib/AccountsService/users/${config.${namespace}.user.name}
          icon_file=/run/current-system/sw/share/excalibur-icons/user/${config.${namespace}.user.name}/${
            config.${namespace}.user.icon.fileName
          }

          if ! [ -d "$(dirname "$config_file")"]; then
            mkdir -p "$(dirname "$config_file")"
          fi

          if ! [ -f "$config_file" ]; then
            echo "[User]
            Session=gnome
            SystemAccount=false
            Icon=$icon_file" > "$config_file"
          else
            icon_config=$(sed -E -n -e "/Icon=.*/p" $config_file)

            if [[ "$icon_config" == "" ]]; then
              echo "Icon=$icon_file" >> $config_file
            else
              sed -E -i -e "s#^Icon=.*$#Icon=$icon_file#" $config_file
            fi
          fi
        '';
      };
    };

    # Required for app indicators
    services = {
      gnome = {
        gnome-initial-setup = disabled;
        gnome-keyring = enabled;
        evolution-data-server = enabled;
        games = disabled;
        tinysparql = enabled;
        localsearch = enabled;
        gnome-browser-connector = enabled;
        gnome-online-accounts = disabled;
        core-utilities = enabled;
        sushi = enabled;
        tracker = enabled;
        at-spi2-core = enabled;
      };
      udev.packages = [ pkgs.gnome-settings-daemon ];
      xserver = {
        enable = true;
        desktopManager.gnome = {
          enable = true;
          extraGSettingsOverridePackages = with pkgs; [
            nautilus-open-any-terminal
            # nautilus-annotations
          ];
          extraGSettingsOverrides = ''
            [org.gnome.desktop.peripherals.touchpad]
            tap-to-click=true
          '';
        };
      };
    };

    programs = {
      dconf = {
        enable = true;
        profiles.user.databases = [
          {
            settings = {
              "org/gnome/desktop/datetime" = {
                automatic-timezone = true;
              };

              "org/gnome/desktop/default/applications/terminal" = {
                exec = "blackbox";
                # exec-arg = "-e";
              };

              "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
                binding = "<Super>e";
                name = "File Manager";
                command = "nautilus -w $HOME";
              };

              "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
                binding = "<Alt>Return";
                command = "blackbox";
                name = "Terminal";
              };

              "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
                binding = "<Primary><Alt>t";
                command = "blackbox";
                name = "Terminal";
              };

              "org/gnome/desktop/peripherals/touchpad" = {
                tap-to-click = true;
              };
            };
          }
        ];
      };

      evince = disabled;
      file-roller = enabled;
      geary = disabled;
      gnome-disks = enabled;
      gnome-documents = disabled;
      gnome-terminal = disabled;

      kdeconnect = {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };
    };

    security = {
      pam.services = {
        # Allow login/authentication with fingerprint or password
        # - https://github.com/NixOS/nixpkgs/issues/171136
        # - https://discourse.nixos.org/t/fingerprint-auth-gnome-gdm-wont-allow-typing-password/35295
        login.fprintAuth = false;
        gdm-fingerprint = mkIf config.${namespace}.hardware.fingerprint.enable {
          text = ''
            auth       required                    pam_shells.so
            auth       requisite                   pam_nologin.so
            auth       requisite                   pam_faillock.so      preauth
            auth       required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so
            auth       optional                    pam_permit.so
            auth       required                    pam_env.so
            auth       [success=ok default=1]      ${pkgs.gnome.gdm}/lib/security/pam_gdm.so
            auth       optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so

            account    include                     login

            password   required                    pam_deny.so

            session    include                     login
            session    optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
          '';
        };
        # gdm.enableGnomeKeyring = true;
      };
    };

    # Open firewall for samba connections to work.
    networking.firewall.extraCommands = "iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns";

    xdg = {
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        configPackages = [ pkgs.gnome-session ];
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome
          # xdg-desktop-portal-gtk
        ];
        config = {
          common = {
            default = [ "gnome" "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
        };
      };
      terminal-exec = {
        enable = true;
        settings = {
          GNOME = [ "com.raggesilver.BlackBox.desktop" ];
          default = [ "com.raggesilver.BlackBox.desktop" ];
        };
        package = pkgs.blackbox-terminal;
      };
    };
  };
}
