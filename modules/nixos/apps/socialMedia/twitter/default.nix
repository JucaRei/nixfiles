{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.socialMedia.twitter;
in
{
  options.${namespace}.apps.socialMedia.twitter = with types; {
    enable = mkBoolOpt false "Whether or not to enable Twitter.";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs.excalibur; [ twitter ]; };
}
