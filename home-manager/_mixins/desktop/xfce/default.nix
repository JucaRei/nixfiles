{ config, pkgs, lib, ... }:
with lib.hm.gvariant; {
  imports = [
    ./gtk.nix
  ];

  home = {
    packages = with pkgs; [ qt5ct qt6ct ];
    sessionVariables.QT_QPA_PLATFORMTHEME = "qt5ct";
  };
  # xdg = {
  #   portal.configPackages = lib.mkDefault [ pkgs.xfce.xfce4-session ];
  # };
}
