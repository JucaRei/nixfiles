{ config, pkgs, lib, namespace, ... }:
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.mail.thunderbird;
in
{
  options.${namespace}.programs.graphical.mail.thunderbird = {
    enable = lib.mkEnableOption "Thunderbird";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.thunderbird;
      description = "Thunderbird package to use";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
