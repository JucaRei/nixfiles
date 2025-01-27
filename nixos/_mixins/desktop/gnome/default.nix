{ config, lib, pkgs, isInstall, ... }:
let
  inherit (lib) mkDefault mkIf mkForce optionals;
  isWayland = if (config.services.xserver.displayManager.gdm.wayland == true) then "wayland" else "x11";
in
{
  config = {

    desktop = {
      features = {
        flatpak-appcenter.enable = true;
      };
      apps = {
        celluloid.enable = true;
        libreoffice.enable = true;
      };
    };

    features.graphics = {
      backend = isWayland;
    };


    environment = {
      gnome.excludePackages = with pkgs // pkgs.gnome; [
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
      ];

      systemPackages =
        with pkgs // pkgs.gnomeExtensions ;
        [
          blackbox-terminal
        ]
        ++ optionals isInstall [
          eyedropper
          gnome.gnome-tweaks
        ];
    };

    programs = {
      calls.enable = false;
      dconf.profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/datetime" = {
              automatic-timezone = true;
            };

            "org/gnome/desktop/default/applications/terminal" = {
              exec = "blackbox";
              exec-arg = "-e";
            };

            "org/gnome/desktop/peripherals/touchpad" = {
              tap-to-click = true;
            };
          };
        }
      ];
      evince.enable = false;
      file-roller.enable = isInstall;
      geary.enable = false;
      gnome-disks.enable = isInstall;
      gnome-terminal.enable = false;
      seahorse.enable = isInstall;
    };

    # Allow login/authentication with fingerprint or password
    # - https://github.com/NixOS/nixpkgs/issues/171136
    # - https://discourse.nixos.org/t/fingerprint-auth-gnome-gdm-wont-allow-typing-password/35295
    security.pam.services.login.fprintAuth = false;
    security.pam.services.gdm-fingerprint = mkIf config.services.fprintd.enable {
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
    security.pam.services.gdm.enableGnomeKeyring = true;

    services = {
      gnome = {
        gnome-initial-setup.enable = false;
        evolution-data-server.enable = mkForce isInstall;
        games.enable = false;
        gnome-browser-connector.enable = isInstall;
        gnome-online-accounts.enable = isInstall;
        # gnome-remote-desktop.enable = true;
        core-utilities = {
          enable = true;
        };
        tracker.enable = true;
        tracker-miners.enable = true;
      };
      udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
      xserver = {
        enable = true;
        displayManager = {
          gdm = {
            enable = true;
            autoSuspend = false;
            wayland = mkDefault false;
          };
        };
        desktopManager.gnome = {
          enable = true;
          # extraGSettingsOverridePackages = with pkgs; [
          #   nautilus-open-any-terminal
          #   nautilus-annotations
          # ];
          # extraGSettingsOverrides = ''
          #   [org.gnome.desktop.peripherals.touchpad]
          #   tap-to-click=true
          # '';
        };
      };
    };

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
          default = [ "com.raggesilver.BlackBox.desktop" ];
        };
      };
    };
  };
}
