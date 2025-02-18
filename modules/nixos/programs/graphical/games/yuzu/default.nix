{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.games.yuzu;
in
{
  options.${namespace}.programs.graphical.games.yuzu = with types; {
    enable = mkBoolOpt false "Whether or not to enable Yuzu.";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs; [ yuzu-mainline ]; };
}
