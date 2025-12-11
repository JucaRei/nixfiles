{ config, pkgs, lib, isWorkstation, desktop, notVM, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf;
  username = "juca";
in
{
  home = {
    sessionVariables = {
      FLAKE = "/home/${username}/.dotfiles/nixfiles";
    };
    file = {
      ".face" = mkIf (desktop != null) {
        source = "${pkgs.juca-avatar}/share/faces/juca.jpg";
      };

      ".config/home-manager/installed-packages.txt" = {
        text =
          let
            packages = builtins.map (p: "${p.name}") config.home.packages;
            sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
            formatted = builtins.concatStringsSep "\n" sortedUnique;
          in
          "${formatted}";
      };

      "workspace/iso's/nixos-console.conf" = mkIf (notVM) {
        text = ''
          #!/run/current-system/sw/bin/quickemu --vm
          guest_os="linux"
          disk_img="nixos-console/disk.qcow2"
          disk_size="25G"
          iso="nixos-console/nixos.iso"
        '';
      };
      "workspace/iso's/nixos-gnome.conf" = mkIf (notVM) {
        text = ''
          #!/run/current-system/sw/bin/quickemu --vm
          guest_os="linux"
          disk_img="nixos-gnome/disk.qcow2"
          disk_size="25G"
          iso="nixos-gnome/nixos.iso"
          width="1920"
          height="1080"
        '';
      };
      "workspace/iso's/nixos-mate.conf" = mkIf (notVM) {
        text = ''
          #!/run/current-system/sw/bin/quickemu --vm
          guest_os="linux"
          disk_img="nixos-mate/disk.qcow2"
          disk_size="25G"
          iso="nixos-mate/nixos.iso"
          width="1920"
          height="1080"
        '';
      };
      "workspace/iso's/nixos-pantheon.conf" = mkIf (notVM) {
        text = ''
          #!/run/current-system/sw/bin/quickemu --vm
          guest_os="linux"
          disk_img="nixos-pantheon/disk.qcow2"
          disk_size="25G"
          iso="nixos-pantheon/nixos.iso"
          width="1920"
          height="1080"
        '';
      };

      "/workspace/iso's/nixos-console/.keep" = mkIf (notVM) { text = ""; };
      "/workspace/iso's/nixos-gnome/.keep" = mkIf (notVM) { text = ""; };
      "/workspace/iso's/nixos-mate/.keep" = mkIf (notVM) { text = ""; };
      "/workspace/iso's/nixos-pantheon/.keep" = mkIf (notVM) { text = ""; };
      "/workspace/.keep".text = "";
      "/.dotfiles/.keep".text = "";
    };
  };

  xdg = {
    enable = isLinux;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";

    userDirs = {
      enable = isLinux && isWorkstation;
      createDirectories = isWorkstation;
      download = "${config.home.homeDirectory}/Downloads";
      # desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      publicShare = "${config.home.homeDirectory}/.local/share/public";
      templates = "${config.home.homeDirectory}/.local/share/templates";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";

      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/screenshots";
        XDG_WALLPAPERS_DIR = "${config.xdg.userDirs.pictures}/wallpapers";
        XDG_GAMES_DIR = "${config.home.homeDirectory}/games";
        XDG_MISC_DIR = "${config.home.homeDirectory}/misc";
        XDG_WORKSPACE_DIR = "${config.home.homeDirectory}/workspace";
        XDG_RECORD_DIR = "${config.xdg.userDirs.videos}/Record";
      };
    };
  };

  systemd = {
    user.tmpfiles.rules = mkIf isLinux [
      "d ${config.home.homeDirectory}/workspace 0755 ${username} users - -"

      "d ${config.home.homeDirectory}/Videos/animes/movies 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Videos/animes/series 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Videos/animes/OVAs 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Videos/series 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Videos/movies 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Videos/youtube 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Music/playlists 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Music/albums 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Music/singles 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Music/artists 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Music/downloads 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Music/records 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/games 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/workspace/iso's/windows 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/workspace/iso's/linux 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/workspace/iso's/mac 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/workspace/iso's/nixos-desktop 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/workspace/iso's/nixos-console 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Pictures/family 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Pictures/backup 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Pictures/phones 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Pictures/screenshots 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Pictures/wallpapers 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/Pictures/resources 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"

      "d ${config.home.homeDirectory}/.config/home-manager 0755 ${username} users - -"
    ];
  };
}
