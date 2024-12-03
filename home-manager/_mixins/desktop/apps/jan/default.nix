{ lib, pkgs, platform, username, config, ... }:

let
  installFor = [ "juca" ];
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) types mkIf mkOption;
  cfg = config.desktop.apps.blackbox;
in
{
  options.desktop.apps.blackbox = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    home = mkIf (lib.elem username installFor) {
      packages = [
        pkgs.jan # 100% offline ChatGPT-alternative AI
      ];
    };
  };
}
