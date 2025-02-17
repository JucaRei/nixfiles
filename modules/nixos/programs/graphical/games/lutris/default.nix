{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.games.lutris;
in
{
  options.${namespace}.programs.graphical.games.lutris = with types; {
    enable = mkBoolOpt false "Whether or not to enable Lutris.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lutris
      # Needed for some installers like League of Legends
      openssl
      gnome.zenity
    ];
  };
}
