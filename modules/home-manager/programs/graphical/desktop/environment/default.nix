{ config, desktop, lib, pkgs, username, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkForce optional mkIf mkDefault;

  is_X11 = if ("${pkgs.elogind}/bin/loginctl show-session 2 -p Type" == "Type=x11") then true else false;
in
{
  # import the DE specific configuration and any user specific desktop configuration
  imports = [
    # ./apps
    # ./features
  ]
  ++ optional (builtins.pathExists (./. + "/${desktop}")) ./${desktop}
    # ++ optional (builtins.pathExists (./. + "/${desktop}/${username}/default.nix")) ./${desktop}/${username}
  ;

  config = {
    # Authrorize X11 access in Distrobox
    home = {
      sessionPath = [
        "$HOME/.local/bin"
        "$HOME/.local/share/applications"
      ];

      # sessionVariables = {
      #   # prevent wine from creating file associations
      #   WINEDLLOVERRIDES = "winemenubuilder.exe=d";
      # };
    };

    gtk = {
      gtk3 = {
        bookmarks = [
          "file:///home/${username}/Documents"
          "file:///home/${username}/Downloads"
          "file:///home/${username}/Pictures"
          "file:///home/${username}/Pictures/screenshots"
          "file:///home/${username}/Pictures/wallpapers"
          "file:///home/${username}/Music"
          "file:///home/${username}/Videos"
          "file:///home/${username}/docker"
          "file:///home/${username}/games"
          "file:///home/${username}/workspace"
          "file:///home/${username}/virtualmachines"
          "smb://10.10.10.200/volume_1 hd400gb"
          "smb://10.10.10.200/volume_2/Transmission/Volume_2 h2tb"
          "smb://10.10.10.1/extermalhd hdwrt"
        ];
      };
    };

    desktop.apps.browser = {
      chrome-based-browser = mkDefault {
        enable = false;
        browser = "brave";
        disableWayland = is_X11;
      };

      firefox-based-browser = mkDefault {
        enable = true;
        browser = "firefox";
        disableWayland = is_X11;
      };
    };

    # features.mime.defaultApps = {
    #   enable = true;
    # };

    # https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
    services.mpris-proxy.enable = isLinux;
  };
}
