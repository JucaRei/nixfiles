{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (pkgs.stdenv) isLinux;
  cfg = config.system.scripts.captive-portal;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      coreutils-full
      gawk
      iproute2
      xdg-utils
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.captive-portal = {
      enable = mkOption {
        default = false;
        type = lib.types.bool;
        description = "enables captive-portal script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
