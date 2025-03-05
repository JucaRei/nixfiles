{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkIf;
  cfg = config.system.scripts.disrun;

  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      coreutils-full
      util-linux
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.disrun = {
      enable = mkOption {
        default = false;
        type = lib.types.bool;
        description = "enables disrun script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
