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
  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "adaptive";
      left-handed = false;
      natural-scroll = false;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };
  };
}
