{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.office.logseq;
in
{
  options.${namespace}.programs.graphical.office.logseq = with types; {
    enable = mkBoolOpt false "Whether or not to enable logseq.";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ logseq ]; };
}
