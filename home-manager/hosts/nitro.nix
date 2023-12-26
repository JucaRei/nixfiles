{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
{
  imports = [
    # ../_mixins/console/neovim.nix
    ../_mixins/apps/video/mpv.nix
    ../_mixins/dev/nix.nix
    # ../_mixins/apps/text-editor/vscodium.nix
    # ../_mixins/apps/text-editor/vscode.nix
    ../_mixins/apps/browser/brave.nix
    # ../_mixins/apps/browser/chromium.nix
    # ../_mixins/apps/browser/firefox.nix
    # ../_mixins/apps/text-editor/sublime.nix
  ];
  # dconf.settings = {
  #   "org/gnome/desktop/background" = {
  #     picture-options = "zoom";
  #     # picture-uri = "file://${config.home.homeDirectory}/Pictures/Determinate/DeterminateColorway-3440x1440.png";
  #   };
  # };

  config = {
    home.packages = with pkgs; [
      whatsapp-for-linux # Whatsapp desktop messaging app
      # icloudpd
      # vlc
      clonegit
      # deezer-gui
      # fantezy
      gcc
      gnumake
      lua
      fcitx5-with-addons
      vt-view
      # neovim
      # tmux
      # sniffnet
      # autorandr
      # thorium
    ];

    dconf.settings = {
      # "org/gnome/desktop/interface" = {
      #   show-battery-percentage = true;
      # };

      # Virtmanager
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
    # modules.desktop.browsers.chromium.enable = true;
  };
}
