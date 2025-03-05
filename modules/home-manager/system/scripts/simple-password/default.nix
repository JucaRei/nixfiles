{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.simple-password;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [ coreutils-full ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.simple-password = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's simple-password script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
