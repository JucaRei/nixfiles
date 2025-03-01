{ config, lib, pkgs, username, isWorkstation, ... }:
let
  inherit (lib) mkIf mkForce;
  cfg = config.features.audio;


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
  config = mkIf (cfg.manager == "pulseaudio") {
    hardware.pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull; # JACK support, Bluetooth
      extraConfig = builtins.toString ''
        # automatically switch to newly-connected devices
        load-module module-switch-on-connect

        # In user's ~/.config/pulse/client.conf set:
        # default-server = unix:/run/pulse.socket
        load-module module-native-protocol-unix auth-anonymous=1 socket=/run/pulse.socket
      '';

      # pulseaudio.tcp.enable = true;
      # pulseaudio.tcp.anonymousClients = {
      #   allowAll = true;
      #   allowedIpRanges = [ "127.0.0.1" ];
      # };
      # pulseaudio.zeroconf.discovery.enable = true;
      # pulseaudio.zeroconf.publish.enable = true;


      # Writes to /etc/pulse/daemon.conf
      daemon.config = { default-sample-rate = 48000; };
    };

    services.pipewire = {
      enable = mkForce false;
      audio.enable = false;
    };

    environment.systemPackages = mkIf config.services.xserver.enable [

      pkgs.pavucontrol
      pkgs.pamixer
    ]
      # ++ (mkIf (isWorkstation) [
      #   sound-volume-up
      #   sound-volume-down
      # ])
    ;

    systemd.services.audio-off = {
      description = "Mute audio before suspend";
      enable = true;
      serviceConfig.ExecStart = "${pkgs.pamixer}/bin/pamixer --mute";
      serviceConfig.RemainAfterExit = true;
      serviceConfig.Type = "oneshot";
      serviceConfig.User = "${username}";
      wantedBy = [ "sleep.target" ];
    };
  };
}
