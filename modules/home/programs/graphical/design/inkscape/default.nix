{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.design.inkscape;
in
{
  options.${namespace}.programs.graphical.design.inkscape = with types; {
    enable = mkBoolOpt false "Whether or not to enable Inkscape.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      inkscape-with-extensions
      google-fonts
    ];
  };
}
