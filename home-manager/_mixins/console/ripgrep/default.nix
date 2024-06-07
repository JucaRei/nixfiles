{ lib, config, ... }:
with lib;
let
  cfg = config.services.ripgrep;
in
{
  options.services.ripgrep = {
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
