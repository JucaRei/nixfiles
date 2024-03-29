{
  inputs,
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    # inputs.flatpaks.homeManagerModules.default
  ];
  # Flatpak declarative
  services.flatpak = {
    # enable = true;
    enableModule = true;
    deduplicate = true;
    state-dir = "${config.home.homeDirectory}/.local/state/flatpak-module";
    target-dir = "${config.home.homeDirectory}/.local/share/flatpak";
    packages = [
      # "flathub:app/org.kde.index//stable"
      # "flathub-beta:app/org.kde.kdenlive/x86_64/stable"
      "flathub:app/info.febvre.Komikku//stable"
      # "flathub:app/com.bitwarden.desktop//stable"

      ## out-of-tree flatpaks can be installed like this (note: they can't be a URL because flatpak doesn't like that)
      # ":${./foobar.flatpak}"
      # "flathub:/root/testflatpak.flatpakref"

      "flathub:app/org.kde.isoimagewriter//stable"

      # <remote name>:<type>/<flatpak ref>/<arch>/<branch>:<commit>
    ];
    preInitCommand = "";
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
    };
    overrides = {
      "global" = {
        filesystems = [
          "home"
          # "!~/Games/Heroic"
        ];
        environment = {"MOZ_ENABLE_WAYLAND" = 1;};
        sockets = ["!x11" "fallback-x11"];
      };
    };
  };

  systemd.user.tmpfiles.rules = [
    "d ${config.home.homeDirectory}/.local/share/flatpak 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/.local/state/flatpak-module 0755 ${username} users - -"
  ];

  # home = {
  #   packages = [ pkgs.flatpak ];
  #   sessionVariables = {
  #     XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"; # lets flatpak work
  #   };
  # };

  #services.flatpak.enable = true;
  #services.flatpak.packages = [ { appId = "com.kde.kdenlive"; origin = "flathub";  } ];
  #services.flatpak.update.onActivation = true;
}
