{ desktop, lib, pkgs, config, ... }: {


  config = {
    # Enable the threadirqs kernel parameter to reduce pipewire/audio latency
    boot = {
      # - Inpired by: https://github.com/musnix/musnix/blob/master/modules/base.nix#L56
      kernelParams = [ "threadirqs" ];
    };
    environment = {
      systemPackages = with pkgs;
        [
          alsa-utils
          pulseaudio
          pulsemixer # Terminal PulseAudio mixer
        ]
        ++ lib.optionals (desktop != null) [
          pavucontrol # Terminal Media Controller
        ];
      etc = {
        "pipewire/pipewire.conf.d/99-allowed-rates.conf".text = builtins.toJSON {
          "context.properties"."default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 358000 384000 716000 768000 ];
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
    services = with lib; {
      pipewire = mkDefault {
        enable = true;
        alsa.enable = true;
        # Enable 32-bit support if driSupport32Bit is true
        alsa.support32Bit = mkForce config.hardware.opengl.driSupport32Bit;
        jack.enable = false;
        pulse.enable = true;
        wireplumber = {
          enable = true;
          # https://stackoverflow.com/questions/24040672/the-meaning-of-period-in-alsa
          # https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/alsa.html#alsa-buffer-properties
          # cat /nix/store/*-wireplumber-*/share/wireplumber/main.lua.d/99-alsa-lowlatency.lua
          # cat /nix/store/*-wireplumber-*/share/wireplumber/wireplumber.conf.d/99-alsa-lowlatency.conf
          configPackages = lib.mkIf useLowLatencyPipewire [
            (pkgs.writeTextDir "share/wireplumber/main.lua.d/99-alsa-lowlatency.lua" ''
              alsa_monitor.rules = {
                {
                  matches = {{{ "node.name", "matches", "*_*put.*" }}};
                  apply_properties = {
                    ["audio.format"] = "S16LE",
                    ["audio.rate"] = 48000,
                    -- api.alsa.headroom: defaults to 0
                    ["api.alsa.headroom"] = 128,
                    -- api.alsa.period-num: defaults to 2
                    ["api.alsa.period-num"] = 2,
                    -- api.alsa.period-size: defaults to 1024, tweak by trial-and-error
                    ["api.alsa.period-size"] = 512,
                    -- api.alsa.disable-batch: USB audio interface typically use the batch mode
                    ["api.alsa.disable-batch"] = false,
                    ["resample.quality"] = 4,
                    ["resample.disable"] = false,
                    ["session.suspend-timeout-seconds"] = 0,
                  },
                },
              }
            '')
          ];
        };
        # https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Config-PipeWire#quantum-ranges
        extraConfig.pipewire."92-low-latency" = lib.mkIf useLowLatencyPipewire {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 64;
            "default.clock.min-quantum" = 64;
            "default.clock.max-quantum" = 64;
          };
          "context.modules" = [
            {
              name = "libpipewire-module-rt";
              args = {
                "nice.level" = -11;
                "rt.prio" = 88;
              };
            }
          ];
        };
        extraConfig.pipewire-pulse."92-low-latency" = lib.mkIf useLowLatencyPipewire {
          "pulse.properties" = {
            "pulse.default.format" = "S16";
            "pulse.fix.format" = "S16LE";
            "pulse.fix.rate" = "48000";
            "pulse.min.frag" = "64/48000"; # 1.3ms
            "pulse.min.req" = "64/48000"; # 1.3ms
            "pulse.default.frag" = "64/48000"; # 1.3ms
            "pulse.default.req" = "64/48000"; # 1.3ms
            "pulse.max.req" = "64/48000"; # 1.3ms
            "pulse.min.quantum" = "64/48000"; # 1.3ms
            "pulse.max.quantum" = "64/48000"; # 1.3ms
          };
          "stream.properties" = {
            "node.latency" = "64/48000"; # 1.3ms
            "resample.quality" = 4;
            "resample.disable" = false;
          };
        };
      };
    };
    hardware = {
      pulseaudio.enable = lib.mkDefault false;
      #extraConfig = "\n    load-module module-switch-on-connect\n  ";
    };
    # Recent fix for pipewire-pulse breakage
    #systemd.user.services.pipewire-pulse.path = [pkgs.pulseaudio];

    security = {
      rtkit = {
        enable = true;
      };
    };
  };
}
