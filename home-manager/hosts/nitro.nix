{ config, lib, pkgs, test ? import ../_mixins/config/testing/test.nix, ... }:
with lib.hm.gvariant; {
  imports = [
    # ../_mixins/console/neovim.nix
    ../_mixins/apps/video/mpv/mpv.nix
    # ../_mixins/apps/tools/transmission.nix
    ../_mixins/dev/nix.nix
    ../_mixins/console/yt-dlp.nix
    # ../_mixins/apps/text-editor/vscodium.nix
    #../_mixins/apps/text-editor/vscode.nix
    ../_mixins/apps/text-editor/vscode/vscode.nix
    # ../_mixins/apps/terminal/urxvt.nix
    # ../_mixins/apps/browser/floorp.nix
    # ../_mixins/apps/browser/chromium.nix
    # ../_mixins/apps/browser/firefox/librewolf.nix
    # ../_mixins/services/flatpak.nix
    # ../_mixins/apps/text-editor/sublime.nix
  ];
  # dconf.settings = {
  #   "org/gnome/desktop/background" = {
  #     picture-options = "zoom";
  #     # picture-uri = "file://${config.home.homeDirectory}/Pictures/Determinate/DeterminateColorway-3440x1440.png";
  #   };
  # };

  config = {
    home = {
      packages = with pkgs; [
        spotdl
        # whatsapp-for-linux # Whatsapp desktop messaging app
        # icloud-photo-downloader
        # vlc
        # cloneit
        # unstable.vscode-fhs
        #unstable.vscode-with-extensions
        # deezer-gui
        # fantezy
        # gcc
        # gnumake
        # transmission_4-gtk
        # lua
        # fcitx5-with-addons
        # vv
        # gparted
        # neovim
        # tmux
        # sniffnet
        # autorandr
        # thorium
      ];

      # keyboard = {
      #   layout = "br";
      #   model = "pc105";
      #   options = "grp:alt_shift_toggle";
      #   variant = "abnt2";
      # };

      file.".config/testingFOLDER/testing.txt".text = ''
        ${test.name}
      '';
    };

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
    nix.settings = {
      extra-substituters = [ "https://nitro.cachix.org" ];
      extra-trusted-public-keys = [ "nitro.cachix.org-1:Z4AoDBOqfAdBlAGBCoyEZuwIQI9pY+e4amZwP94RU0U=" ];
    };
  };
}
