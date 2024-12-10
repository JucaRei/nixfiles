{ lib, config, packages, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps.chat.matrix;
in
{
  options = {
    desktop.apps.chat.matrix = {
      enable = mkEnableOption "Enables Matrix client.";
    };
  };
  config = cfg.enable {
    home = {
      packages = with packages; [
        fractal
      ];
    };
  };
}
