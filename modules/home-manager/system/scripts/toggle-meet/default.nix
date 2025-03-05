{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.toggle-meet;
  inherit (pkgs.stdenv) isLinux;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      coreutils-full
      xdotool
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.toggle-meet = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's toggle-meet script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
