{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
{
  imports = [
    ../_mixins/console/fish.nix
    ../_mixins/apps/video/mpv.nix
  ];
  # dconf.settings = {
  #   "org/gnome/desktop/background" = {
  #     picture-options = "zoom";
  #     # picture-uri = "file://${config.home.homeDirectory}/Pictures/Determinate/DeterminateColorway-3440x1440.png";
  #   };
  # };

  home.packages = with pkgs; [
    whatsapp-for-linux # Whatsapp desktop messaging app
    icloudpd
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      show-battery-percentage = true;
    };

    # Virtmanager
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
