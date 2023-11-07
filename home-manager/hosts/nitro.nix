{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
{
  imports = [
    # ../_mixins/console/fish.nix
    ../_mixins/apps/video/mpv.nix
    # ../_mixins/apps/text-editor/vscodium.nix
    ../_mixins/apps/text-editor/vscode.nix
    ../_mixins/apps/browser/librewolf.nix
    # ../_mixins/apps/text-editor/sublime.nix
  ];
  # dconf.settings = {
  #   "org/gnome/desktop/background" = {
  #     picture-options = "zoom";
  #     # picture-uri = "file://${config.home.homeDirectory}/Pictures/Determinate/DeterminateColorway-3440x1440.png";
  #   };
  # };

  home.packages = with pkgs; [
    whatsapp-for-linux # Whatsapp desktop messaging app
    # icloudpd
    vlc
    clonegit
    # thorium
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
