{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.games.r2modman;
in
{
  options.${namespace}.apps.games.r2modman = with types; {
    enable = mkBoolOpt false "Whether or not to enable r2modman.";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs; [ r2modman ]; };
}
