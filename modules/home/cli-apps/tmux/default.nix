{ lib
, config
, pkgs
, namespace
, ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.cli-apps.tmux;
in
{
  options.${namespace}.cli-apps.tmux = {
    enable = mkEnableOption "Tmux";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ excalibur.tmux ]; };
}
