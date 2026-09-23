{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.system.programs.shells;
in
{
  config = mkIf (cfg.enable && cfg.default == "fish") {
    programs.fish = {
      enable = true;
    };
  };
}
