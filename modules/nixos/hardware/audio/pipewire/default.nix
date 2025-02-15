{ lib, config, pkgs, namespace, ... }:
let
  inherit (lib.${namespace}) mkOpt;
  inherit (lib) mkIf mkForce optional types;
  username = config.${namespace}.user.name;
  cfg = config.${namespace}.hardware.audio;
  low_latency = config.features.audio."pipewire".useLowLatencyPipewire;
in
{
  options.${namespace}.hardware.audio."pipewire".useLowLatencyPipewire =
    # mkOption {
    #   type = types.bool;
    #   default = false;
    #   description = "Whether enable low latency configuration.";
    # };
    mkOpt types.bool false "Whether enable low latency configuration.";

  config = mkIf (cfg.manager == "pipewire") {

    # Enable the threadirqs kernel parameter to reduce pipewire/audio latency
    boot = mkIf cfg.enable {
      # - Inpired by: https://github.com/musnix/musnix/blob/master/modules/base.nix#L56
      kernelParams = [ "threadirqs" ];
    };

    environment.systemPackages =
      with pkgs; [
        alsa-utils
        playerctl
        pulseaudio
        pulsemixer
        pwvucontrol
      ];

    hardware.pulseaudio.enable = mkForce false;

    services = {
      # https://nixos.wiki/wiki/PipeWire
      # https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Config-PipeWire#quantum-ranges
      # Debugging
      #  - pw-top                                            # see live stats
      #  - journalctl -b0 --user -u pipewire                 # see logs (spa resync is "bad")
      #  - pw-metadata -n settings 0                         # see current quantums
      #  - pw-metadata -n settings 0 clock.force-quantum 128 # override quantum
      #  - pw-metadata -n settings 0 clock.force-quantum 0   # disable override
      pipewire = {
        enable = true;
        alsa.enable = true;
        # Enable 32-bit support if driSupport32Bit is true
        alsa.support32Bit = mkForce config.hardware.graphics.enable32Bit;
        jack.enable = false;
        pulse.enable = true;
        wireplumber = {
          enable = true;
          # https://stackoverflow.com/questions/24040672/the-meaning-of-period-in-alsa
          # https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/alsa.html#alsa-buffer-properties
          # cat /nix/store/*-wireplumber-*/share/wireplumber/main.lua.d/99-alsa-lowlatency.lua
          # cat /nix/store/*-wireplumber-*/share/wireplumber/wireplumber.conf.d/99-alsa-lowlatency.conf
          configPackages = mkIf (low_latency == true) [
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

            (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-bluez.conf" ''
              monitor.bluez.properties = {
                bluez5.roles = [ a2dp_sink a2dp_source bap_sink bap_source hsp_hs hsp_ag hfp_hf hfp_ag ]
                bluez5.codecs = [ sbc sbc_xq aac ]
                bluez5.enable-sbc-xq = true
                bluez5.hfphsp-backend = "native"
              }
            '')
          ];
        };
        # https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Config-PipeWire#quantum-ranges
        extraConfig.pipewire."92-low-latency" = mkIf (low_latency == true) {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 64;
            "default.clock.min-quantum" = 64;
            "default.clock.max-quantum" = 64;
          };
          "context.modules" = [
            {
              name = "ipewire-module-rt";
              args = {
                "nice.level" = -11;
                "rt.prio" = 88;
              };
            }
          ];
        };
        extraConfig.pipewire-pulse."92-low-latency" = mkIf (low_latency == true) {
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

    users.users.${username}.extraGroups = optional cfg.enable "audio";
  };
}
