{ lib, config, pkgs, ... }: {
  services =
    let
      inherit (lib) mkIf mkForce;
      isXorg = if ("${pkgs.uutils-coreutils-noprefix}/bin/echo $XDG_SESSION_TYPE" == "x11") then true else false;
    in
    {
      xserver = mkIf (config.features.graphics.backend != "wayland") {
        # FUCK NVIDIA
        config = mkForce ''
          Section "ServerLayout"
            Identifier "layout"
            Screen "nvidia" 0 0
          EndSection

          Section "Module"
            Load "modesetting"
            Load "glx"
          EndSection

          Section "Device"
            Identifier "nvidia"
            Driver "nvidia"
            BusID "PCI:1:0:0"
            Option "AllowEmptyInitialConfiguration"
          EndSection

          Section "Device"
            Identifier "intel"
            Driver "modesetting"
            Option "AccelMethod" "sna"
          EndSection

          Section "Screen"
            Identifier     "nvidia"
            Device         "nvidia"
            DefaultDepth    24
            Option         "AllowEmptyInitialConfiguration"
            SubSection     "Display"
              Depth       24
              Modes      "nvidia-auto-select"
            EndSubSection
          EndSection

          Section "Screen"
            Identifier "intel"
            Device "intel"
          EndSection
        '';
        displayManager = mkIf isXorg {
          setupCommands = ''
            RIGHT='eDP-1'
            LEFT='HDMI-1-0'
            ${lib.getExe pkgs.xorg.xrandr} --output $LEFT --mode 1920x1080 --rotate right --output $LEFT --mode 1920x1080 --rotate left --right-of $LEFT
          '';
          sessionCommands = ''${lib.getExe pkgs.xorg.xrandr} --output eDP-1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal'';
        };

        ## xrandrHeads = [
        ##   {
        ##     output = "HDMI-1-0";
        ##     monitorConfig = ''
        ##       Option "PreferredMode"  "1920x1080"
        ##       Option "Primary"        "true"
        ##       Option "RightOf"        "eDP-1"
        ##     '';
        ##   }
        ##   {
        ##     output = "eDP-1";
        ##     monitorConfig = ''
        ##       Option "right-of" "DP1"
        ##       Option "Rotate" "left"
        ##       Option "PreferredMode" "1920x1080"
        ##     '';
        ##   }
        ## ];

        # xrandrHeads = [
        #   {
        #     output = "eDP-1";
        #     primary = true;
        #     monitorConfig = ''
        #       Option "PreferredMode" "1920x1080"
        #       Option "Position" "1920 0"
        #     '';
        #   }
        #   {
        #     output = "HDMI-1-0";
        #     primary = false;
        #     monitorConfig = ''
        #       Option "PreferredMode" "1920x1080"
        #       Option "Position" "0 0"
        #     '';
        #   }
        # ];
        # This must be done manually to ensure my screen spaces are arranged
        # exactly as I need them to be *and* the correct monitor is "primary".
        # Using xrandrHeads does not work.
        # monitorSection = ''
        #   VendorName     "PlayStation"
        #   Identifier     "HDMI-1-0"
        #   HorizSync       30.0 - 81.0
        #   VertRefresh     50.0 - 75.0
        #   Option         "DPMS"
        # '';
        # screenSection = ''
        #   Option "metamodes" "HDMI-0: nvidia-auto-select +1920+0, DP-1: 1920x1080_75 +0+0"
        #   Option "SLI" "Off"
        #   Option "MultiGPU" "Off"
        #   Option "BaseMosaic" "o ff"
        #   Option "Stereo" "0"
        #   Option "nvidiaXineramaInfoOrder" "DFP-1"
        # '';


        # Section "Monitor"
        # Monitor Identity - Typically HDMI-0 or DisplayPort-0
        # Identifier    "HDMI1"

        # Setting Resolution and Modes
        # Modeline is usually not required, but you can force resolution with it
        # Modeline "1920x1080" 172.80 1920 2040 2248 2576 1080 1081 1084 1118
        # Option "PreferredMode" "1920x1080"
        # Option        "TargetRefresh" "60"

        # Positioning the Monitor
        # Basic
        # Option "LeftOf or RightOf or Above or Below" "DisplayPort-0"
        # Advanced
        # Option        "Position" "1680 0"

        # Disable a Monitor
        # Option        "Disable" "true"
        # EndSection .

        resolutions = [

          # { x = 2048; y = 1152; }
          { x = 1920; y = 1080; }
          { x = 1600; y = 900; }
          { x = 1366; y = 768; }
          # { x = 2560; y = 1440; }
          # { x = 3072; y = 1728; }
          # { x = 3840; y = 2160; }
        ];
      };
    };
}
