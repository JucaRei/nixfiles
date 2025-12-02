{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.system.programs.multimedia.rhythmbox;
in
{
  options = {
    enable = mkEnableOption "Enable's rhythmbox with custom settings as default";
  };

  config = mkIf cfg.enable { };
}
