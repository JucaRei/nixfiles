{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.graphics.pitivi;
in
{
  options.${namespace}.programs.graphical.graphics.pitivi = with types; {
    enable = mkBoolOpt false "Whether or not to enable Pitivi.";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs; [ pitivi ]; };
}
