{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mkForce;
  inherit (lib.types) bool;
  cfg = config.system.services.wallpapers;

  aesthetic-wallpapers = pkgs.fetchgit {
    url = "https://github.com/D3Ext/aesthetic-wallpapers";
    rev = "060c580dcc11afea2f77f9073bd8710920e176d8";
    sha256 = "5MnW630EwjKOeOCIAJdSFW0fcSSY4xmfuW/w7WyIovI=";
  };
in
{
  options = {
    system.services.wallpapers = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable's wallapapers for desktop";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      file = {
        "${config.xdg.userDirs.pictures}/wallpapers".source = mkForce "${aesthetic-wallpapers}/images";
      };
    };
  };
}
