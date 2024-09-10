{ lib, config, ... }:
let
  inherit (lib) mkOption types mkIf;
  cfg = config.custom.console.ripgrep;
in
{
  options.custom.console.ripgrep = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    programs = {
      ripgrep = {
        arguments = [
          "--colors=line:style:bold"
          "--max-columns-preview"
          "--smart-case"
        ];
        enable = true;
      };
    };
  };
}
