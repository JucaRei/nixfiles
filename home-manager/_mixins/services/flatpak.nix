{ config, pkgs, username, lib, ... }:
with lib;
let
  cfg = config.services.flatpak-nix;
in
{
  options.services.flatpak-nix = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    # Flatpak declarative
    services.flatpak = {
      # enable = true;
      enableModule = mkForce true;
      deduplicate = true;
      state-dir = "${config.home.homeDirectory}/.local/state/flatpak-module";
      target-dir = "${config.home.homeDirectory}/.local/share/flatpak";
      packages = [
        "flathub:app/info.febvre.Komikku/x86_64/stable"
        "flathub:app/com.ktechpit.whatsie/x86_64/stable"
        "flathub:app/io.bassi.Amberol/x86_64/stable"

        ## out-of-tree flatpaks can be installed like this (note: they can't be a URL because flatpak doesn't like that)
        # ":${./foobar.flatpak}"
        # "flathub:/root/testflatpak.flatpakref"

        #"gnome-nightly:app/org.gnome.Epiphany.Devel//master"

        # "flathub:app/org.kde.isoimagewriter//stable"

        # <remote name>:<type>/<flatpak ref>/<arch>/<branch>:<commit>
      ];
      # preInitCommand = "";
      remotes = {
        flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        flathub-beta = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
        gnome-nightly = "https://nightly.gnome.org/gnome-nightly.flatpakrepo";
      };
      overrides = {
        "global" = {
          filesystems = [
            "home"
            # "!~/Games/Heroic"
          ];
          environment = { "MOZ_ENABLE_WAYLAND" = 1; };
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
