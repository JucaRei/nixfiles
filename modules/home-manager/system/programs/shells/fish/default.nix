{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.system.programs.shells;
in
{
  config = mkIf (cfg.default == "fish") {
    programs.fish = {
      enable = true;

      interactiveShellInit = mkIf (cfg.direnv == true) ''
        ${pkgs.direnv}/bin/direnv hook fish | source
      '';

      shellInit = mkIf (cfg.direnv == true) ''
        ${pkgs.direnv}/bin/direnv hook fish | source
      '';
    };
  };
}
