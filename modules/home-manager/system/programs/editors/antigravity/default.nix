{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption;
  inherit (lib.types) package;
  cfg = config.system.programs.editors.antigravity;
in
{
  options = {
    system.programs.editors.antigravity = {
      enable = mkEnableOption "Google Antigravity AI IDE";
      package = mkOption {
        type = package;
        default = pkgs.unstable.antigravity-ide-fhs;
        description = "Package or wrapper for Antigravity IDE.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}
