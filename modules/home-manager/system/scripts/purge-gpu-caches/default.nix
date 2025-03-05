{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.purge-gpu-caches;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      coreutils-full
      fd
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.purge-gpu-caches = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's purge-gpu-caches script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
