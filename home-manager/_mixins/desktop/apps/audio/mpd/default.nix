{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.desktop.apps.audio.mpd;
in
{
  options.desktop.apps.audio.mpd = {
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
