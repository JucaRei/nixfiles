{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.get-volume;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      coreutils-full
      pulsemixer
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.get-volume = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's get-volume script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
