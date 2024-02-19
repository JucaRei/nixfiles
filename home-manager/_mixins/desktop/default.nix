{ config, desktop, pkgs, username, lib, ... }:
let inherit (pkgs.stdenv) isLinux;
in {
  imports = [
    # ../services/emote.nix

    # (./. + "./${desktop}")
    # ../apps/documents/libreoffice.nix
    # ../services/flatpak.nix
    ../console/properties.nix
    ../apps/browser/brave
    ../fonts
  ] ++ lib.optional (builtins.pathExists (./. + "/${desktop}")) ./${desktop}
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix"))
    ./${desktop}.nix ++ lib.optional
    (builtins.pathExists (./. + "/../../users/${username}/desktop.nix"))
    ../../users/${username}/desktop.nix;

  services = {
    # https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
    mpris-proxy.enable = isLinux;

    udiskie = {
      enable = true;
      tray = "auto";
      automount = true;
    };
  };

  home = {
    packages = with pkgs;
      [
        # font-manager
        # dconf2nix
        hexchat
      ];
  };
}
