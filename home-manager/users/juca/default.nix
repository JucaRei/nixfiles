{ config, pkgs, lib, isWorkstation, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf;
  username = "juca";
in
{
  home = {
    sessionVariables = { };
    file = {
      ".config/home-manager/installed-packages.txt" = {
        text =
          let
            packages = builtins.map (p: "${p.name}") config.home.packages;
            sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
            formatted = builtins.concatStringsSep "\n" sortedUnique;
          in
          "${formatted}";
      };
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
      "d ${config.home.homeDirectory}/virtualmachines/windows 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/virtualmachines/linux 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/virtualmachines/mac 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/virtualmachines/nixos-desktop 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/virtualmachines/nixos-console 0755 ${username} users - -"
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
