{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.games.steam;
in
{
  options.${namespace}.programs.graphical.games.steam = with types; {
    enable = mkBoolOpt false "Whether or not to enable support for Steam.";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      extest.enable = true;
      localNetworkGameTransfers.openFirewall = true;
      protontricks.enable = true;
      remotePlay.openFirewall = true;

      extraCompatPackages = [ pkgs.proton-ge-bin.steamcompattool ];
    };

    hardware.steam-hardware.enable = true;

    # Enable GameCube controller support.
    services.udev.packages = [ pkgs.dolphinEmu ];

    environment.systemPackages = with pkgs.excalibur; [ steam ];

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    };
  };
}
