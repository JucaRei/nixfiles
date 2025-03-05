{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.nh-home;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      bc
      coreutils-full
      nh
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.nh-home = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's nh-home script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
    programs.fish.shellAliases = {
      build-home = "nh-home build";
      switch-home = "nh-home switch";
    };
  };
}
