{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.programs.graphical.apps.multimedia.mpd;
in
{
  options.programs.graphical.apps.multimedia.mpd = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    services = {
      mpd = {
        enable = true;
        musicDirectory = "~/${config.home.homeDirectory}/Media/Music";
        extraConfig = ''
          audio_output {
              type            "pipewire"
              name            "PipeWire Sound Server"
          }
        '';
      };
    };
  };
}
