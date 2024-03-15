{ desktop, lib, pkgs, hostname, username, ... }:
# with lib;
# with builtins;
let
  #   xorg = (elem "xorg" config.sys.hardware.graphics.desktopProtocols);
  #   wayland = (elem "wayland" config.sys.hardware.graphics.desktopProtocols);
  #   desktopMode = xorg || wayland;

  defaultDns = [ "1.1.1.1" "1.0.0.1" ];
  isInstall = if (builtins.substring 0 4 hostname != "iso-") then true else false;
  needsLowLatencyPipewire = if (hostname == "vm" || hostname == "scrubber") then true else false;
  saveBattery = if (hostname != "scrubber" && hostname != "vader") then true else false;
  hasRazerPeripherals = if (hostname == "phasma" || hostname == "vader") then true else false;
  isGamestation = if (hostname == "phasma" || hostname == "vader") && (desktop != null) then true else false;

  # Define DNS settings for specific users
  # - https://cleanbrowsing.org/filters/
  userDnsSettings = {
    # Security Filter:
    # - Blocks access to phishing, spam, malware and malicious domains.
    juca = [ "185.228.168.9" "185.228.169.9" ];

    # Adult Filter:
    # - Blocks access to all adult, pornographic and explicit sites.
    # - It does not block proxy or VPNs, nor mixed-content sites.
    # - Sites like Reddit are allowed.
    # - Google and Bing are set to the Safe Mode.
    # - Malicious and Phishing domains are blocked.
    teste = [ "185.228.168.10" "185.228.169.11" ];

    # Family Filter:
    # - Blocks access to all adult, pornographic and explicit sites.
    # - It also blocks proxy and VPN domains that are used to bypass the filters.
    # - Mixed content sites (like Reddit) are also blocked.
    # - Google, Bing and Youtube are set to the Safe Mode.
    # - Malicious and Phishing domains are blocked.
    teste2 = [ "185.228.168.168" "185.228.169.168" ];
  };
in
{
  # config = mkIf desktopMode {
  imports =
    [
      ../services/network/networkmanager.nix
    ]
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix"))
      ./${desktop}.nix;

  # Conditionally set Public DNS based on username, defaulting if user not matched
  networking.networkmanager.insertNameservers =
    if builtins.hasAttr username userDnsSettings then
      userDnsSettings.${username}
    else
      defaultDns;
  wifi = {
    backend = "iwd";
    powersave = saveBattery;
  };

  # Fix issue with java applications and tiling window managers.
  environment.sessionVariables = {
    "_JAVA_AWT_WM_NONREPARENTING" = "1";
  };

  boot = {
    # Enable the threadirqs kernel parameter to reduce audio latency
    # - Inpired by: https://github.com/musnix/musnix/blob/master/modules/base.nix#L56
    kernelParams = lib.mkDefault [ "quiet" "vt.global_cursor_default=0" "mitigations=off" "threadirqs" ];
    plymouth.enable =
      if hostname != "rasp3"
      then lib.mkDefault true
      else false;
  };

  environment = {
    etc =
      let
        json = pkgs.formats.json { };
      in
      {
        "backgrounds/DeterminateColorway-1920x1080.png".source = ../config/backgrounds/DeterminateColorway-1920x1080.png;
        "backgrounds/DeterminateColorway-1920x1200.png".source = ../config/backgrounds/DeterminateColorway-1920x1200.png;
        "backgrounds/DeterminateColorway-2560x1440.png".source = ../config/backgrounds/DeterminateColorway-2560x1440.png;
        "backgrounds/DeterminateColorway-3440x1440.png".source = ../config/backgrounds/DeterminateColorway-3440x1440.png;
        "backgrounds/DeterminateColorway-3840x2160.png".source = ../config/backgrounds/DeterminateColorway-3840x2160.png;
      } // lib.optionalAttrs (needsLowLatencyPipewire) {
        # Change this to use: services.pipewire.extraConfig.pipewire
        # https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Config-PipeWire#quantum-ranges
        "pipewire/pipewire.conf.d/92-low-latency.conf".text = ''
          context.properties = {
            default.clock.rate          = 48000
            default.clock.allowed-rates = [ 48000 ]
            default.clock.quantum       = 64
            default.clock.min-quantum   = 64
            default.clock.max-quantum   = 64
          }
          context.modules = [
            {
              name = libpipewire-module-rt
              args = {
                nice.level = -11
                rt.prio = 88
              }
            }
          ]
        '';
        # Change this to use: services.pipewire.extraConfig.pipewire-pulse
        "pipewire/pipewire-pulse.d/92-low-latency.conf".source = json.generate "92-low-latency.conf" {
          context.modules = [
            {
              name = "libpipewire-module-protocol-pulse";
              args = {
                pulse.min.req = "64/48000";
                pulse.default.req = "64/48000";
                pulse.max.req = "64/48000";
                pulse.min.quantum = "64/48000";
                pulse.max.quantum = "64/48000";
              };
            }
          ];
          stream.properties = {
            node.latency = "64/48000";
            resample.quality = 4;
          };
        };
        # https://stackoverflow.com/questions/24040672/the-meaning-of-period-in-alsa
        # https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/alsa.html#alsa-buffer-properties
        # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/3241
        # cat /nix/store/*-wireplumber-*/share/wireplumber/main.lua.d/50-alsa-config.lua
        "wireplumber/main.lua.d/92-low-latency.lua".text = ''
          alsa_monitor.rules = {
            {
              matches = {
                {
                  -- Matches all sources.
                  { "node.name", "matches", "alsa_input.*" },
                },
                {
                  -- Matches all sinks.
                  { "node.name", "matches", "alsa_output.*" },
                },
              },
              apply_properties = {
                ["audio.rate"] = "48000",
                ["api.alsa.headroom"] = 128,             -- Default: 0
                ["api.alsa.period-num"] = 2,             -- Default: 2
                ["api.alsa.period-size"] = 512,          -- Default: 1024
                ["api.alsa.disable-batch"] = false,      -- generally, USB soundcards use the batch mode
                ["resample.quality"] = 4,
                ["resample.disable"] = false,
                ["session.suspend-timeout-seconds"] = 0,
              },
            },
          }
        '';
      };

    systemPackages = with pkgs; lib.optionals (isInstall) [
      appimage-run
      pavucontrol
      pulseaudio
      wmctrl
      xdotool
      ydotool
      # ] ++ lib.optionals (isGamestation) [
      #   mangohud
      # ] ++ lib.optionals (isInstall && hasRazerPeripherals) [
      #   polychromatic
    ];
  };


  services = {
    # Disable xterm
    xserver = {
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
    };
    samba = {
      enable =
        if hostname != "rasp3"
        then true
        else false;
      #package = pkgs.unstable.samba4Full; # samba4Full broken
      extraConfig = ''
        client min protocol = NT1
      '';
    };
    gvfs = {
      package = pkgs.unstable.gvfs;
      enable = true;
    };

    clight = {
      enable =
        if hostname != "rasp3"
        then true
        else false;
      settings = {
        verbose = true;
        backlight.disabled = true;
        dpms.timeouts = [ 900 300 ];
        dimmer.timeouts = [ 870 270 ];
        gamma.long_transitions = true;
        screen.disabled = true;
      };
    };

    # Configure the logind service with custom parameters
    # This NixOS configuration snippet adjusts the settings for the logind service, specifically focusing on the runtime directories. The parameters set include:
    # - `RuntimeDirectorySize=100%`: Allows runtime directories to use up to 100% of the available space, dynamically adjusting to the available disk space.
    # - `RuntimeDirectoryInodesMax=1048576`: Sets the maximum number of inodes in runtime directories to 1,048,576, limiting the total number of files and directories that can be created.
    # These configurations aim to manage resources effectively and prevent potential issues related to disk space exhaustion or an excessive number of files in user-specific runtime directories.

    logind = {
      extraConfig = ''
        # Set the maximum size of runtime directories to 100%
        RuntimeDirectorySize=100%

        # Set the maximum number of inodes in runtime directories to 1048576
        RuntimeDirectoryInodesMax=1048576
      '';
    };

    # needed for GNOME services outside of GNOME Desktop
    # dbus.packages = if hostname != "rasp3" then [ pkgs.gcr ] else "";

    udev =
      if hostname != "rasp3"
      then {
        packages = with pkgs; [ gnome.gnome-settings-daemon ];
        extraRules = ''
          # add my android device to adbusers
          SUBSYSTEM=="usb", ATTR{idVendor}=="22d9", MODE="0666", GROUP="adbusers"
        '';
      }
      else "";
  };
  # };


  hardware = {
    # smooth backlight control
    brillo.enable =
      if hostname != "rasp3"
      then true
      else false;
    opengl = {
      driSupport = true;
      driSupport32Bit = if (hostname == "nitro") then true else false;
      extraPackages =
        if (hostname == "nitro") then
          (with pkgs; [
            intel-media-driver
            # nvidia-vaapi-driver
            libvdpau
            libvdpau-va-gl
          ]) else "";
      extraPackages32 =
        if (hostname == "nitro") then
          (with pkgs.pkgsi686Linux;
          [
            # intel-media-driver
            #  vaapiIntel
            vaapiVdpau
            libvdpau-va-gl
            #  libva
          ]) else "";
    };
  };

  security = {
    # userland niceness
    rtkit.enable = true;
  };
}
