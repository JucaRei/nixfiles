{ config, lib, pkgs, username, isWorkstation, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkDefault mkIf;
in
{
  imports = lib.optional (builtins.pathExists (./. + "/${username}")) (./. + "/${username}");

  config = {
    home = {
      packages = with pkgs; [
        speedtest-go
        htop
      ];
    };

    system.programs.shells.enable = true;

    systemd = {
      user = {
        sessionVariables = {
          FLAKE = mkDefault "/home/${username}/.dotfiles/nixfiles";
          NIXPKGS_ALLOW_UNFREE = "1";
          NIXPKGS_ALLOW_INSECURE = "1";
        };

        # Create age keys directory for SOPS
        tmpfiles = mkIf isLinux {
          rules = [
            "d ${config.home.homeDirectory}/.config/sops/age 0755 ${username} users - -"
          ];
        };
      };
    };

    xdg = {
      enable = isLinux;
      cacheHome = "${config.home.homeDirectory}/.cache";
      configHome = "${config.home.homeDirectory}/.config";
      dataHome = "${config.home.homeDirectory}/.local/share";
      stateHome = "${config.home.homeDirectory}/.local/state";

      userDirs = {
        enable = isLinux;
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
          XDG_WORKSPACE_DIR = "${config.home.homeDirectory}/lab/workspace";
          XDG_RECORD_DIR = "${config.xdg.userDirs.videos}/Record";
        };
      };
    };
  };
}
