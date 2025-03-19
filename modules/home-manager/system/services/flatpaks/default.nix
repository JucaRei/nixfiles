{ config, username, lib, ... }:
let
  inherit (lib) mkOption mkIf mkForce mkOptionDefault;
  inherit (lib.types) bool;
  cfg = config.system.services.flatpaks;
in
{
  options = {
    system.services.flatpaks = {
      enable = mkOption {
        default = false;
        type = bool;
      };
    };
  };

  config = mkIf cfg.enable {

    # Flatpak declarative
    services.flatpak = {
      packages = [
        # "flathub:app/info.febvre.Komikku/x86_64/stable"
        { appId = "com.ktechpit.whatsie"; origin = "flathub"; }

        ## out-of-tree flatpaks can be installed like this (note: they can't be a URL because flatpak doesn't like that)
        # ":${./foobar.flatpak}"
        # "flathub:/root/testflatpak.flatpakref"

        #"gnome-nightly:app/org.gnome.Epiphany.Devel//master"

        # "flathub:app/org.kde.isoimagewriter//stable"

        # <remote name>:<type>/<flatpak ref>/<arch>/<branch>:<commit>
      ];
      # preInitCommand = "";
      remotes = mkOptionDefault {
        flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        flathub-beta = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
        gnome-nightly = "https://nightly.gnome.org/gnome-nightly.flatpakrepo";
      };
      overrides = {
        global = {
          # Force Wayland by default
          # Context.sockets = [ "wayland" "!x11" "!fallback-x11" ];

          filesystems = [
            "home"
            # "!~/Games/Heroic"
          ];
          environment = {
            # "MOZ_ENABLE_WAYLAND" = 1;

            # Fix un-themed cursor in some Wayland apps
            XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";

            # Force correct theme for some GTK apps
            # GTK_THEME = "Adwaita:dark";
          };
          sockets = [ "!x11" "fallback-x11" ];
        };
      };
    };

    systemd.user.tmpfiles.rules = [
      "d ${config.home.homeDirectory}/.local/share/flatpak 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/.local/state/flatpak-module 0755 ${username} users - -"
    ];
  };
}
