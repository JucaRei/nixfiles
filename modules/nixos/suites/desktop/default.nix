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
        gnome = enabled;

        features = {
          appimage = enabled;
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
      };

      apps = {
        _1password = enabled;
        firefox = enabled;
        vlc = enabled;
        logseq = enabled;
        hey = enabled;
        pocketcasts = enabled;
        yt-music = enabled;
        twitter = enabled;
        gparted = enabled;
      };

    };
  };
}
