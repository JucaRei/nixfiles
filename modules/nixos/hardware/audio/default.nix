{ config, lib, username, ... }:
let
  inherit (lib) mkOption mkIf types;
  inherit (lib.types) nullOr enum bool;
  cfg = config.hardware.audio;
  manager = cfg.manager;
in
{
  imports = [
    ./pipewire
    ./pulseaudio
  ];

  options = {
    hardware.audio = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable audio system manager";
      };
      manager = mkOption {
        type = nullOr (enum [ "pipewire" "pulseaudio" ]);
        default = null;
        description = "Default audio system manager";
      };
    };
  };

  config = mkIf (cfg.enable && cfg.manager != null) {
    # Allow members of the "audio" group to set RT priorities
    security = {
      # Inspired by musnix: https://github.com/musnix/musnix/blob/master/modules/base.nix#L87
      pam.loginLimits = [
        {
          domain = "@audio";
          item = "memlock";
          type = "-";
          value = "unlimited";
        }
        {
          domain = "@audio";
          item = "rtprio";
          type = "-";
          value = "99";
        }
        {
          domain = "@audio";
          item = "nofile";
          type = "soft";
          value = "99999";
        }
        {
          domain = "@audio";
          item = "nofile";
          type = "hard";
          value = "99999";
        }
      ];
      rtkit.enable = true;
    };
    services = {
      # use `lspci -nn`
      udev.extraRules = ''
        # Remove AMD Audio devices; if present
        # ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{class}=="0xab28", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA Audio devices; if present
        # ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
        # Expose important timers the members of the audio group
        # Inspired by musnix: https://github.com/musnix/musnix/blob/master/modules/base.nix#L94
        KERNEL=="rtc0", GROUP="audio"
        KERNEL=="hpet", GROUP="audio"
        # Allow users in the audio group to change cpu dma latency
        DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
      '';
    };

    users.users.${username}.extraGroups = [ "rtkit" ];
  };
}
