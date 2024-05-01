{ pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      conky
      lua
      jq
      wirelesstools

      #Fonts
      dosis
      roboto
      bebasNeue
      feather
      abel
    ];

    file = {
      "${config.xdg.configHome}/conky/Regulus/Regulus.conf" = {
        source = ../../../config/conky/regulus/Regulus.conf;
        recursive = true;
      };
      "${config.xdg.configHome}/conky/Regulus/res" = {
        source = ../../../config/conky/regulus/res;

      };
      "${config.xdg.configHome}/conky/Regulus/scripts/rings-v1.2.1.lua" = {
        source = ../../../config/conky/regulus/scripts/rings-v1.2.1.lua;
      };
      "${config.xdg.configHome}/conky/Regulus/scripts/weather-text-icon" = {
        executable = true;
        source = ../../../config/conky/regulus/scripts/weather-text-icon;
      };
      "${config.xdg.configHome}/conky/Regulus/scripts/playerctl.sh" = {
        executable = true;
        source = ../../../config/conky/regulus/scripts/playerctl.sh;
      };
      "${config.xdg.configHome}/conky/Regulus/scripts/weather-v2.0.sh" = {
        executable = true;
        source = ../../../config/conky/regulus/scripts/weather-v2.0.sh;
      };
      "${config.xdg.configHome}/conky/Regulus/scripts/ssid" = {
        executable = true;
        source = ../../../config/conky/regulus/scripts/ssid;
      };
    };
  };
}
