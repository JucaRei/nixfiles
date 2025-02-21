{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.social.element;
in
{
  options.${namespace}.programs.graphical.social.element = with types; {
    enable = mkBoolOpt false "Whether or not to enable Element.";
  };

  config = mkIf cfg.enable {
    ${namespace}.home.extraOptions = {
      home.packages = with pkgs; [ element-desktop ];
    };
  };
}
