{ pkgs, config, lib, ... }:
with lib;
let
  cfg = options.services.fastfetch;
in
{
  options.services.fastfetch = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = {
    home = {
      packages = pkgs.fastfetch;
      file = {
        "${config.xdg.configHome}/fastfetch/config.jsonc".text =
          builtins.readFile ../config/fastfetch/fastfetch.jsonc;
      };
      shellAliases = { neofetch = "${pkgs.fastfetch}"; };
    };
  };
}
