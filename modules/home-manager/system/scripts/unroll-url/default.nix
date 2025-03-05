{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.unroll-url;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      coreutils-full
      curlMinimal
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.unroll-url = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's unroll-url script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
