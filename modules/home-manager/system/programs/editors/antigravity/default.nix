{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption;
  inherit (lib.types) package;
  cfg = config.system.programs.editors.antigravity;
  isNixOS = osConfig != null;
in
{
  options = {
    system.programs.editors.antigravity = {
      enable = mkEnableOption "Google Antigravity AI IDE";
      package = mkOption {
        type = package;
        default = if isNixOS then pkgs.unstable.antigravity-ide-fhs else pkgs.unstable.antigravity-ide;
        description = "Package or wrapper for Antigravity IDE.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];

    home.shellAliases = {
      antigravity = "antigravity-ide";
    };
  };
}
