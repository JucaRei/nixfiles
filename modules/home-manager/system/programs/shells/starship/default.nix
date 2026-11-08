{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.system.programs.shells;
  c = config.desktop.theme.colors;
in
{
  config = mkIf (cfg.enable && cfg.starship.enable) {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;

      settings = import ./_settings.nix {
        inherit
          lib
          config
          c
          ;
      };
    };
  };
}
