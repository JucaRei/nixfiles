{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.terminal.tools.bottom;
in
{
  options.${namespace}.programs.terminal.tools.bottom = with types; {
    enable = mkBoolOpt false "Whether or not to enable Bottom.";
  };

  config = mkIf cfg.enable {
    ${namespace}.home.extraOptions = {
      home.packages = with pkgs; [ bottom ];
    };
  };
}
