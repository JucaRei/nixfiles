{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.social.twitter;
in
{
  options.${namespace}.programs.graphical.social.twitter = with types; {
    enable = mkBoolOpt false "Whether or not to enable Twitter.";
  };

  config = mkIf cfg.enable {
    # home.packages = with pkgs.${namespace}; [ twitter ];
  };
}
