{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
let
  testing = import ../_mixins/config/testing/test.nix { name = "iT Works"; };
  font-search = pkgs.writeShellScriptBin "font-search" ''
    fc-list \
        | grep -ioE ": [^:]*$1[^:]+:" \
        | sed -E 's/(^: |:)//g' \
        | tr , \\n \
        | sort \
        | uniq
  '';
in
# with test;
with lib;
{
  imports = [
    # ../_mixins/console/neovim.nix
    ../_mixins/apps/video/mpv/mpv.nix
    # ../_mixins/apps/tools/transmission.nix
    ../_mixins/dev/nix.nix
    ../_mixins/console/gpg.nix
    ../_mixins/console/bash.nix
    ../_mixins/console/yt-dlp.nix
    # ../_mixins/console/aria2.nix
    # ../_mixins/apps/text-editor/vscodium.nix
    #../_mixins/apps/text-editor/vscode.nix
    ../_mixins/apps/text-editor/vscode/vscode.nix
    ../_mixins/apps/documents/zathura.nix
    # ../_mixins/apps/terminal/urxvt.nix
    # ../_mixins/apps/browser/floorp.nix
    # ../_mixins/apps/browser/chromium.nix
    # ../_mixins/apps/browser/firefox/firefox.nix
    ../_mixins/apps/browser/brave
    # ../_mixins/apps/browser/firefox/librewolf.nix
    ../_mixins/services/flatpak.nix
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
        # spotdl
        # whatsapp-for-linux # Whatsapp desktop messaging app
        # icloud-photo-downloader
        # (wrapProgram vlc)
        # cloneit
        # deezer-gui
        # fantezy
        transmission_4-gtk
        nix-whereis
        # nf-iosevka
        gedit
        neovim
        font-search
        unstable.obsidian
        # fcitx5-with-addons
        # vv
        # gparted
        # tmux
        # thorium
      ];

      keyboard = lib.mkForce {
        # layout = "br,us";
        layout = lib.mkForce "br";
        model = lib.mkForce "pc105"; # "pc104alt";
        # options = [
        # "grp:shifts_toggle"
        # "eurosign:e"
        # ];
        # variant = "abnt2";
        # variant = "nodeadkeys"; # "nodeadkeys";
        # variant = # "intl"/ "alt-intl" / "altgr-intl"
        #/ "mac" / # "mac_nodeadkeys"
      };

      # file.".config/testingFOLDER/testing.txt".text = ''
      #   ${testing}
      # '';
    };

    services = {
      bash.enable = false;
      # firefox.enable = false;
      flatpak-nix.enable = true;
      yt-dlp-custom.enable = true;
      brave.enable = true;
      # aria2.enable = true;
      flatpak.packages = [
        "flathub:app/dev.aunetx.deezer/x86_64/stable"
      ];
    };

    programs = {
      # yt-dlp.enable = true;
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
