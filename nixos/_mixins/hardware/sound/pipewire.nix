{ desktop, lib, pkgs, ... }:
{
  imports = [ ../../services/security/rtkit.nix ];
  environment = {
    systemPackages = with pkgs; [
      alsa-utils
      pulseaudio
      pulsemixer # Terminal PulseAudio mixer
    ] ++ lib.optionals (desktop != null) [
      pavucontrol # Terminal Media Controller
    ];
    etc = {
      "pipewire/pipewire.conf.d/99-allowed-rates.conf".text = builtins.toJSON {
        "context.properties"."default.clock.allowed-rates" = [
          44100
          48000
          88200
          96000
          176400
          192000
          358000
          384000
          716000
          768000
        ];
      };
      # "pipewire/pipewire-pulse.conf.d/99-resample.conf".text =
      #   builtins.toJSON { "stream.properties"."resample.quality" = 15; };
      # "pipewire/client.conf.d/99-resample.conf".text =
      #   builtins.toJSON { "stream.properties"."resample.quality" = 15; };
      # "pipewire/client-rt.conf.d/99-resample.conf".text =
      #   builtins.toJSON { "stream.properties"."resample.quality" = 15; };
      "pipewire/pipewire.conf.d/92-fix-resync.conf".text = ''
      context.properties = {
        default.clock.rate = 48000
        default.clock.quantum = 1024
        default.clock.min-quantum = 1024
        default.clock.max-quantum = 1024
      }
    '';
    };
  };
  #security.rtkit.enable = true;
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      #alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
      #lowLatency = {
      ## enable this module
      #enable = true;
      ## defaults (no need to be set unless modified)
      #quantum = 64;
      #rate = 48000;
      socketActivation = true;
    };
  };
  hardware = {
    pulseaudio.enable = lib.mkForce false;
    #extraConfig = "\n    load-module module-switch-on-connect\n  ";
  };
  # Recent fix for pipewire-pulse breakage
  #systemd.user.services.pipewire-pulse.path = [pkgs.pulseaudio];
}
