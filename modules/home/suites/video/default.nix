{ config
, lib
, pkgs
, namespace
, ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt enabled disabled;

  cfg = config.${namespace}.suites.video;
in
{
  options.${namespace}.suites.video = {
    enable = mkBoolOpt false "Whether or not to enable video configuration.";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      lib.optionals stdenv.isLinux [
        celluloid
        devede
        # handbrake
        mediainfo-gui
        shotcut
        vlc
      ]
      ++ lib.optionals stdenv.isDarwin [ iina ];

    excalibur = {
      programs = {
        graphical.apps = {
          obs = disabled;
          mpv = enabled;
          spicetify = enabled;
        };
      };
    };
  };
}
