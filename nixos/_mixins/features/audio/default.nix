{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    ./pipewire
    ./pulseaudio
  ];

  options = {
    features.audio.manager = mkOption {
      type = types.enum [ "pipewire" "pulseaudio" null ];
      default = "pipewire"; # null;
      description = "Default audio system manager";
    };
  };
}
