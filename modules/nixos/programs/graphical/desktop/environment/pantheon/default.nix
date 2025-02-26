{ isInstall, lib, pkgs, config, ... }:
# let
# isWayland = if (config.services.xserver.displayManager.gdm.wayland == true) then "wayland" else "x11";
# in
{
  imports = [ ../../display-manager/lightdm ];
  config = {
    system.services.flatpak-appcenter.enable = true;

    programs.graphical.desktop.backend = "wayland"; # isWayland;

    environment = {
      pantheon.excludePackages = with pkgs.pantheon; [
        elementary-calculator
        elementary-camera
        elementary-code
        elementary-music
        elementary-photos
        elementary-videos
        epiphany
      ];
      pathsToLink = [ "/libexec" ];
    };

    programs = {
      evince.enable = false;
      gnome-disks.enable = isInstall;
      seahorse.enable = isInstall;
    };

    # security = {
    #   # Disable autoSuspend; my Pantheon session kept auto-suspending
    #   # - https://discourse.nixos.org/t/why-is-my-new-nixos-install-suspending/19500
    #   polkit.extraConfig = ''
    #     polkit.addRule(function(action, subject) {
    #         if (action.id == "org.freedesktop.login1.suspend" ||
    #             action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
    #             action.id == "org.freedesktop.login1.hibernate" ||
    #             action.id == "org.freedesktop.login1.hibernate-multiple-sessions")
    #         {
    #             return polkit.Result.NO;
    #         }
    #     });
    #   '';
    # };

    services = {
      gnome = {
        evolution-data-server.enable = isInstall;
        gnome-online-accounts.enable = isInstall;
        gnome-keyring.enable = true;
      };
      gvfs.enable = true;
      xserver = {
        enable = true;
        desktopManager = {
          pantheon = {
            enable = true;
            extraWingpanelIndicators = with pkgs; [
              wingpanel-indicator-ayatana
              monitor
            ];
          };
        };
      };
    };

    # App indicator
    # - https://github.com/NixOS/nixpkgs/issues/144045#issuecomment-992487775
    systemd.user.services.indicator-application-service = {
      description = "indicator-application-service";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.indicator-application-gtk3}/libexec/indicator-application/indicator-application-service";
      };
    };

    xdg = {
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
          pantheon.xdg-desktop-portal-pantheon
          xdg-desktop-portal-gtk
        ];
        config = {
          common = {
            default = [ "pantheon" "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
        };
      };
    };
  };
}
