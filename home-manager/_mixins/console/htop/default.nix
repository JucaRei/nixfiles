{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.services.htop;
in
{
  options.services.htop = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = {
    home = {
      packages = [ pkgs.htop ];
      file = {
        "${config.xdg.configHome}/htop/htoprc".text = builtins.readFile ./htoprc;
      };
    };
  };
}
