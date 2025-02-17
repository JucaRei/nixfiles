{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.games.rpcs3;
in
{
  options.${namespace}.programs.graphical.games.rpcs3 = with types; {
    enable = mkBoolOpt false "Whether or not to enable rpcs3.";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs; [ rpcs3 ]; };
}
