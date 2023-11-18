{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
{
  # services.xserver.desktopManager.lxqt.enable = true;
  # environment.lxqt.excludePackages = with pkgs; [ lxqt.qterminal xscreensaver ];
  programs = {
    dconf = {
      enable = true;
    };
  };
}
