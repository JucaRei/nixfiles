{ options
, config
, lib
, pkgs
, namespace
, ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.games;
in
{
  options.${namespace}.suites.games = with types; {
    enable = mkBoolOpt false "Whether or not to enable common games configuration.";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      programs = {
        graphical = {
          games = {
            steam = enabled;
            lutris = enabled;
            # winetricks = enabled;
            protontricks = enabled;
          };
          tools = {
            bottles = enabled;
          };
        };

        terminal = {
          apps = {
            proton = enabled;
          };
          tools = {
            wine = enabled;
          };
        };
      };
    };
  };
}
