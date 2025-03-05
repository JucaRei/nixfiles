{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.random-walls;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      procps
      feh
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.random-walls = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's random-walls script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
