{ lib, pkgs, config, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps.zed-editor;
in
{
  options = {
    desktop.apps.zed-editor = {
      enable = mkEnableOption "Enables zed as editor";
    };
  };
  config = mkIf (cfg.enable && isLinux) {
    home = {
      packages = with pkgs; [ unstable.zed-editor ];
    };
  };
}
