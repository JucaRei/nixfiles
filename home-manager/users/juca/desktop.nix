{ config, lib, pkgs, username, ... }:
let
  inherit (pkgs.stdenv) isLinux;
in
with lib.hm.gvariant; {
  imports = [
    ../../_mixins/apps/music/rhythmbox.nix
    # ../../_mixins/fonts
  ];

  # Authrorize X11 access in Distrobox
  home.file = {
    ".face" = {
      # source = ./face.jpg;
      source = "${pkgs.juca-avatar}/share/faces/juca.jpg";
    };
    # ".distroboxrc" = lib.mkIf isLinux {
    #   text = ''
    #     xhost +si:localuser:$USER
    #   '';
    # };
    # "${config.home.homeDirectory}/Pictures/wallpapers" = lib.mkDefault {
    #   source = ../../_mixins/config/wallpapers;
    #   recursive = true;
    # };
  };
}
