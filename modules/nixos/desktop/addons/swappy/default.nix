{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.addons.swappy;
in
{
  options.${namespace}.desktop.addons.swappy = with types; {
    enable = mkBoolOpt false "Whether to enable Swappy in the desktop environment.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ swappy ];

    excalibur.home.configFile."swappy/config".source = ./config;
    excalibur.home.file."Pictures/screenshots/.keep".text = "";
  };
}
