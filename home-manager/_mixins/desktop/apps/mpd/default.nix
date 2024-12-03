{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.desktop.apps.mpd;
in
{
  options.desktop.apps.mpd = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    services = {
      mpd = {
        enable = true;
        musicDirectory = "~/Music";
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
