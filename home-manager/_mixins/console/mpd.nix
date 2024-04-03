{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.programs.mpd;
in
{
  options.programs.mpd = {
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