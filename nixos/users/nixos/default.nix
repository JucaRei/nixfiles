{ config, desktop, isISO, isWorkstation, lib, pkgs, username, ... }:
let
  isWorkstationISO = isISO && isWorkstation;
  inherit (lib) mkIf mkForce optionals;
in
{
  config = {
    users.users.nixos.description = "NixOS";

    # All configurations for live media are below:
    system = mkIf isISO { stateVersion = mkForce lib.trivial.release; };

    environment = {
      etc = mkIf isWorkstationISO {
        "firefox.dockitem".source = pkgs.writeText "firefox.dockitem" ''
          [PlankDockItemPreferences]
          Launcher=file:///run/current-system/sw/share/applications/firefox.desktop
        '';
        "firefox.dockitem".target = "/plank/firefox.dockitem";

        "io.elementary.files.dockitem".source = pkgs.writeText "io.elementary.files.dockitem" ''
          [PlankDockItemPreferences]
          Launcher=file:///run/current-system/sw/share/applications/io.elementary.files.desktop
        '';
        "io.elementary.files.dockitem".target = "/plank/io.elementary.files.dockitem";

        "io.elementary.terminal.dockitem".source = pkgs.writeText "io.elementary.terminal.dockitem" ''
          [PlankDockItemPreferences]
          Launcher=file:///run/current-system/sw/share/applications/io.elementary.terminal.desktop
        '';
        "io.elementary.terminal.dockitem".target = "/plank/io.elementary.terminal.dockitem";

        "code.dockitem".source = pkgs.writeText "code.dockitem" ''
          [PlankDockItemPreferences]
          Launcher=file:///run/current-system/sw/share/applications/code.desktop
        '';
        "code.dockitem".target = "/plank/code.dockitem";

        "gparted.dockitem".source = pkgs.writeText "gparted.dockitem" ''
          [PlankDockItemPreferences]
          Launcher=file:///run/current-system/sw/share/applications/gparted.desktop
        '';
        "gparted.dockitem".target = "/plank/gparted.dockitem";
      };
      systemPackages = optionals isWorkstationISO [ pkgs.gparted pkgs.vscode-fhs ];
    };

    # All workstation configurations for live media are below.
    isoImage = mkIf isWorkstationISO { edition = mkForce "${desktop}"; };

    programs = {
      dconf.profiles.user.databases = [
        {
          settings =
            with lib.gvariant;
            mkIf isWorkstationISO {
              "net/launchpad/plank/docks/dock1" = {
                dock-items = [
                  "firefox.dockitem"
                  "io.elementary.files.dockitem"
                  "io.elementary.terminal.dockitem"
                  "code.dockitem"
                  "gparted.dockitem"
                ];
              };
              "org/gnome/shell" = {
                disabled-extensions = mkEmptyArray type.string;
                favorite-apps = [
                  "firefox.desktop"
                  "org.gnome.Nautilus.desktop"
                  "org.gnome.Console.desktop"
                  "io.calamares.calamares.desktop"
                  "code.desktop"
                  "gparted.desktop"
                ];
                welcome-dialog-last-shown-version = "9999999999";
              };
              "org/gnome/desktop/background" = {
                picture-options = "zoom";
                picture-uri = "file:///etc/backgrounds/Catppuccin-3840x2160.png";
                picture-uri-dark = "file:///etc/backgrounds/Catppuccin-3840x2160.png";
              };
              "org/gnome/desktop/screensaver" = {
                picture-uri = "file:///etc/backgrounds/Catppuccin-3840x2160.png";
              };
            };
        }
      ];
    };

    services.xserver = {
      displayManager.autoLogin = mkIf isWorkstationISO { user = "${username}"; };
    };

    # Create desktop shortcuts and dock items for the live media
    systemd.tmpfiles = mkIf isWorkstationISO {
      rules =
        [
          "d /home/${username}/Desktop 0755 ${username} users"
          "d /home/${username}/.config 0755 ${username} users"
          "d /home/${username}/.config/plank 0755 ${username} users"
          "d /home/${username}/.config/plank/dock1 0755 ${username} users"
          "d /home/${username}/.config/plank/dock1/launchers 0755 ${username} users"
          "L+ /home/${username}/.config/plank/dock1/launchers/firefox.dockitem - - - - /etc/plank/firefox.dockitem"
          "L+ /home/${username}/.config/plank/dock1/launchers/io.elementary.files.dockitem - - - - /etc/plank/io.elementary.files.dockitem"
          "L+ /home/${username}/.config/plank/dock1/launchers/io.elementary.terminal.dockitem - - - - /etc/plank/io.elementary.terminal.dockitem"
          "L+ /home/${username}/.config/plank/dock1/launchers/code.dockitem - - - - /etc/plank/code.dockitem"
          "L+ /home/${username}/.config/plank/dock1/launchers/gparted.dockitem - - - - /etc/plank/gparted.dockitem"
          "L+ /home/${username}/Desktop/firefox.desktop - - - - ${pkgs.firefox}/share/applications/firefox.desktop"
          "L+ /home/${username}/Desktop/io.calamares.calamares.desktop - - - - ${pkgs.calamares-nixos}/share/applications/io.calamares.calamares.desktop"
          "L+ /home/${username}/Desktop/code.desktop - - - - ${pkgs.vscode-fhs}/share/applications/code.desktop"
          "L+ /home/${username}/Desktop/gparted.desktop - - - - ${pkgs.gparted}/share/applications/gparted.desktop"
        ]
        ++ optionals (isWorkstationISO && desktop == "mate") [
          "L+ /home/${username}/Desktop/caja.desktop - - - - ${pkgs.mate.caja}/share/applications/caja.desktop"
          "L+ /home/${username}/Desktop/mate-terminal.desktop - - - - ${pkgs.mate.mate-terminal}/share/applications/mate-terminal.desktop"
        ];
    };
  };
}
