{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.socialMedia.element;
in
{
  options.${namespace}.apps.socialMedia.element = with types; {
    enable = mkBoolOpt false "Whether or not to enable Element.";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs; [ element-desktop ]; };
}
