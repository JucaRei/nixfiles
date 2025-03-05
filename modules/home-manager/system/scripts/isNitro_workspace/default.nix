{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.isNitro_workspace;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      xorg.xrandr
      bspwm
      gnugrep
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.isNitro_workspace = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's isNitro_workspace script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
