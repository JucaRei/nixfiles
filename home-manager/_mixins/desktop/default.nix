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
