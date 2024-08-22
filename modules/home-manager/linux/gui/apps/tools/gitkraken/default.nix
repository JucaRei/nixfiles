{ config, lib, pkgs, username, ... }:
let
  installFor = [ "juca" ];
  cfg = config.modules.apps.gitkraken;
in
{
  options.modules.apps.gitkraken = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
  };
  config = lib.mkIf (cfg.enable && lib.elem username installFor) {
    home = {
      file = {
        # https://github.com/davi19/gitkraken
        "${config.home.homeDirectory}/.gitkraken/themes/catppuccin_mocha.jsonc".text = builtins.readFile ../../../../../../../resources/configs/gitkraken/gitkraken-catppuccin-mocha-blue.json;
      };
      packages = with pkgs; [ gitkraken ];
    };
  };
}
