{ config
, lib
, namespace
, pkgs
, ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt enabled disabled;

  cfg = config.${namespace}.suites.social;
in
{
  options.${namespace}.suites.social = {
    enable = mkBoolOpt false "Whether or not to enable social configuration.";
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals pkgs.stdenv.isLinux (
      with pkgs;
      [
        caprine-bin # facebook messenger
        element-desktop
        slack
        telegram-desktop
      ]
    );

    excalibur = {
      programs = {
        graphical.apps = {
          discord = disabled;
          caprine = enabled;
        };

        terminal.social = {
          slack-term = disabled;
          twitch-tui = disabled;

        };
      };
    };
  };
}
