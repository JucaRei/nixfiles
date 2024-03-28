{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.services.fastfetch;
in
{
  options.services.fastfetch = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ fastfetch ];
      file = {
        "${config.xdg.configHome}/fastfetch/config.jsonc".text =
          builtins.readFile ../config/fastfetch/fastfetch.jsonc;
      };
      shellAliases = { neofetch = lib.mkForce "${pkgs.fastfetch}"; };
    };
  };
}
