{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.programs.graphical.apps.editor.zed-editor;
in
{
  options = {
    programs.graphical.apps.editor.zed-editor = {
      enable = mkEnableOption "Enables zed as editor";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ unstable.zed-editor ];
    };
  };
}
