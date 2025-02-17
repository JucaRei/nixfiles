{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.games.pcsx2;
in
{
  options.${namespace}.programs.graphical.games.pcsx2 = with types; {
    enable = mkBoolOpt false "Whether or not to enable PCSX2.";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs; [ pcsx2 ]; };
}
