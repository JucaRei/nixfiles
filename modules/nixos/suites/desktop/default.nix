{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.desktop;
in
{
  options.${namespace}.suites.desktop = with types; {
    enable = mkBoolOpt false "Whether or not to enable common desktop configuration.";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      desktop = {
        environment = {
          gnome = enabled;
        };
      };

      system = {
        xkb = enabled;

        security = {
          keyring = enabled;
        };

        services = {
          appimage = enabled;
        };

        fonts = enabled;
      };

      programs = {
        graphical = {
          # browser = {
          # firefox = {
          #   enable = true;
          # };
          # };

          media = {
            vlc = enabled;
          };

          tools = {
            _1password = enabled;
            gparted = enabled;
          };
        };

        terminal = {
          tools = {
            nix-ld = enabled;
          };
        };

      };
    };
  };
}
