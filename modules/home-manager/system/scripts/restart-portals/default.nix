{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.restart-portals;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.restart-portals = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's restart-portals script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
