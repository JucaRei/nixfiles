{ config, pkgs, lib, ... }:
let
  ### Tiling window managers
  sound-volume-up = pkgs.writeScriptBin "sound-volume-up" ''
    #!${pkgs.stdenv.shell}
    set -e

    pactl set-sink-volume @DEFAULT_SINK@ +2%
    notify-send -h string:synchronous:volume "$(pamixer --get-volume-human)" -t 1000
  '';

  sound-volume-down = pkgs.writeScriptBin "sound-volume-down" ''
    #!${pkgs.stdenv.shell}
    set -e

    pactl set-sink-volume @DEFAULT_SINK@ -2%
    notify-send -h string:synchronous:volume "$(pamixer --get-volume-human)" -t 1000
  '';
in
{
  sound.enable = true;

  hardware = {
    # pa-info to debug
    # pacmd list-sinks | grep -e 'name:' -e 'index:'
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull; # JACK support, Bluetooth
      # auto-switch to bluetooth headset
      extraConfig = lib.mkDefault "load-module module-switch-on-connect";

      # Writes to /etc/pulse/daemon.conf
      daemon.config = { default-sample-rate = 48000; };
    };
  };

  environment.systemPackages = lib.mkIf config.services.xserver.enable [
    sound-volume-up
    sound-volume-down
    pkgs.pavucontrol
    pkgs.pamixer
  ];
}
