{ pkgs, config, lib, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.custom.console.fastfetch;
in
{
  options.custom.console.fastfetch = {
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
          builtins.readFile ../../config/fastfetch/fastfetch.jsonc;
      };
      shellAliases = {
        neofetch = lib.mkForce "${pkgs.fastfetch}/bin/fastfetch";
      };
    };
  };
}
