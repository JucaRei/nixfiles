{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.media.yt-music;
in
{
  options.${namespace}.programs.graphical.media.yt-music = with types; {
    enable = mkBoolOpt false "Whether or not to enable YouTube Music.";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs.excalibur; [ yt-music ]; };
}
