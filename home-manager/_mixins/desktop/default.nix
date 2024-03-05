{ config, desktop, pkgs, username, lib, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
in
{
  imports =
    [
      # ../services/emote.nix
      # (./. + "./${desktop}")
      # ../apps/documents/libreoffice.nix
      # ../services/flatpak.nix
      ../console/properties.nix
      ../apps/browser/brave
      ../fonts
    ]
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}")) ./${desktop}
    ++ lib.optional
      (builtins.pathExists (./. + "/../../users/${username}/desktop.nix"))
      ../../users/${username}/desktop.nix;

  services = {
    # https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
    mpris-proxy.enable = isLinux;
  };

  home = {
    # Authrorize X11 access in Distrobox
    file.".distroboxrc" = lib.mkIf isLinux {
      text = ''
        ${pkgs.xorg.xhost}/bin/xhost +si:localuser:$USER
      '';
    };
    packages = with pkgs; [
      black # Code format Python
      nodePackages.prettier # Code format
      shellcheck # Code lint Shell
      shfmt # Code format Shell
      # font-manager
      dconf2nix
      hexchat
    ] ++ lib.optionals (isDarwin) [
      # macOS apps
      iterm2
      pika
      utm
    ];
  };
}
