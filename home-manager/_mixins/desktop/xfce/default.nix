{ config, pkgs, lib, ... }:
with lib.hm.gvariant; {
  imports = [
    ./gtk.nix
  ];

  xdg.portal.configPackages = lib.mkDefault [ pkgs.xfce.xfce4-session ];
  home = {
    packages = with pkgs; [ qt5ct qt6ct ];
    sessionVariables.QT_QPA_PLATFORMTHEME = "qt5ct";
  };
}
