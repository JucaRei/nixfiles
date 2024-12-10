{ lib, username, pkgs, config, isLima, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkDefault;
in
{
  imports = lib.optional (builtins.pathExists (./. + "/${username}")) ./${username};

  xdg = {
    enable = isLinux;
    userDirs = {
      enable = isLinux && !isLima;
      createDirectories = mkDefault true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Media/Pictures/screenshots";
      };
    };
  };
}
