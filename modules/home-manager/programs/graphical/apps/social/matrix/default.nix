{ lib, config, packages, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.programs.graphical.apps.social.matrix;
in
{
  options = {
    programs.graphical.apps.social.matrix = {
      enable = mkEnableOption "Enables Matrix client.";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = with packages; [
        fractal
      ];
    };
  };
}
