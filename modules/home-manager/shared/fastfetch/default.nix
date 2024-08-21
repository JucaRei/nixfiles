{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.modules.fastfetch;
in
{
  options.modules.fastfetch = {
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
          builtins.readFile ../../../../resources/configs/fastfetch/fastfetch.jsonc;
      };
      shellAliases = {
        neofetch = lib.mkForce "${lib.getExe pkgs.fastfetch}";
      };
    };
  };
}
