{ config, desktop, lib, pkgs, username, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkForce optional mkIf mkDefault;

  aesthetic-wallpapers = pkgs.fetchgit {
    url = "https://github.com/D3Ext/aesthetic-wallpapers";
    rev = "060c580dcc11afea2f77f9073bd8710920e176d8";
    sha256 = "5MnW630EwjKOeOCIAJdSFW0fcSSY4xmfuW/w7WyIovI=";
  };
in
{
  # import the DE specific configuration and any user specific desktop configuration
  imports = [ ./apps ./features ]
    ++ optional (builtins.pathExists (./. + "/${desktop}")) ./${desktop}
    ++ optional (builtins.pathExists (./. + "/${desktop}/${username}/default.nix")) ./${desktop}/${username};

  config = {
    # Authrorize X11 access in Distrobox
    home = {
      file = mkIf isLinux {
        ".distroboxrc".text = ''${pkgs.xorg.xhost}/bin/xhost +si:localuser:$USER'';
        ".face" = { source = "${pkgs.juca-avatar}/share/faces/juca.jpg"; };
        "${config.xdg.userDirs.pictures}/wallpapers".source = mkForce "${aesthetic-wallpapers}/images";
      };

      sessionVariables = {
        # prevent wine from creating file associations
        WINEDLLOVERRIDES = "winemenubuilder.exe=d";
      };
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
        disableWayland = true;
      };

      firefox-based-browser = mkDefault {
        enable = true;
        browser = "firefox";
        disableWayland = true;
      };
    };

    # features.mime.defaultApps = {
    #   enable = true;
    # };

    # https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
    services.mpris-proxy.enable = isLinux;
  };
}
