{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.system.programs.multimedia.rhythmbox;
in
{
  # Declara a opção no mesmo módulo que a implementa (padrão do repositório).
  options.system.programs.multimedia.rhythmbox = {
    enable = mkEnableOption "Rhythmbox music player";
  };

  config = mkIf cfg.enable { };
}
