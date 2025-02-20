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
        environments = {
          gnome = enabled;
        };

        addons = {
          wallpapers = enabled;
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
          browser = {
            firefox = enabled;
          };

          media = {
            vlc = enabled;
          };

          tools = {
            _1password = enabled;
          };
        };

        terminal = {
          tools = {
            gparted = enabled;
            nix-ld = enabled;
          };
        };
      };

    };
  };
}
