{ desktop, lib, pkgs, hostname, username, isInstall, ... }:
with lib;
# with builtins;
let
  #   xorg = (elem "xorg" config.sys.hardware.graphics.desktopProtocols);
  #   wayland = (elem "wayland" config.sys.hardware.graphics.desktopProtocols);
  #   desktopMode = xorg || wayland;

  notVM = if (hostname == "minimech" || hostname == "scrubber" || hostname == "vm" || builtins.substring 0 5 hostname == "lima-" || hostname == "rasp3") then false else true;

  defaultDns = [ "1.1.1.1" "1.0.0.1" ];
  needsLowLatencyPipewire = if (hostname == "vm" || hostname == "scrubber") then true else false;
  saveBattery = if (hostname != "scrubber" && hostname != "vader") then true else false;
  hasRazerPeripherals = if (hostname == "phasma" || hostname == "vader") then true else false;
  isGamestation = if (hostname == "phasma" || hostname == "vader") && (desktop != null) then true else false;
  isNitro = if (hostname == "nitro") then true else false;

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
  networking = {
    networkmanager = {
      # Conditionally set Public DNS based on username, defaulting if user not matched
      insertNameservers =
        if builtins.hasAttr username userDnsSettings then
          userDnsSettings.${username}
        else
          defaultDns;
      wifi = {
        backend = "iwd";
        powersave = saveBattery;
      };
    };
  };

  boot = {
    # Enable the threadirqs kernel parameter to reduce audio latency & Quiet Boot
    # - Inpired by: https://github.com/musnix/musnix/blob/master/modules/base.nix#L56
    kernelParams = lib.mkDefault [
      "quiet"
      "vt.global_cursor_default=0"
      "systemd.show_status=auto"
      "udev.log_level=3"
      "rd.udev.log_level=3"
      "mitigations=off"
      "threadirqs"
    ];
    plymouth.enable =
      if (hostname != "rasp3" || "soyo")
      then lib.mkDefault true
      else false;
  };

  environment = {
    etc = {

      # Allow mounting FUSE filesystems as a user.
      # https://discourse.nixos.org/t/fusermount-systemd-service-in-home-manager/5157
      "fuse.conf".text = ''
        user_allow_other
      '';

      "backgrounds/DeterminateColorway-1920x1080.png".source = ../config/backgrounds/DeterminateColorway-1920x1080.png;
      "backgrounds/DeterminateColorway-1920x1200.png".source = ../config/backgrounds/DeterminateColorway-1920x1200.png;
      "backgrounds/DeterminateColorway-2560x1440.png".source = ../config/backgrounds/DeterminateColorway-2560x1440.png;
      "backgrounds/DeterminateColorway-3440x1440.png".source = ../config/backgrounds/DeterminateColorway-3440x1440.png;
      "backgrounds/DeterminateColorway-3840x2160.png".source = ../config/backgrounds/DeterminateColorway-3840x2160.png;
    } // lib.optionalAttrs (isNitro) {
      "aspell.conf".text = ''
        master en_US
        add-extra-dicts en-computers.rws
        add-extra-dicts pt_BR.rws
      '';
    };

    # Eject nano and perl from the system
    defaultPackages = with pkgs; mkForce [
      coreutils-full
      micro
    ];

    systemPackages = with pkgs; (optionals (isInstall) [
      # appimage-run
      # pavucontrol
      # pulseaudio
      # wmctrl
      # xdotool
      # ydotool
      # ] ++ lib.optionals (isGamestation) [
      #   mangohud
      # ] ++ lib.optionals (isInstall && hasRazerPeripherals) [
      #   polychromatic
    ] ++ lib.optionals (isNitro) [
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.pt_BR
      hunspellDicts.en_US
      hunspellDicts.pt_BR
    ]);
  };


  services = {
    # Disable xterm
    xserver = {
      excludePackages = lib.mkIf (hostname != "soyo") [ pkgs.xterm ];
      desktopManager.xterm.enable = lib.mkIf (hostname != "soyo") false;
      # Disable autoSuspend; my Pantheon session kept auto-suspending
      # - https://discourse.nixos.org/t/why-is-my-new-nixos-install-suspending/19500
      # displayManager.gdm.autoSuspend = if (desktop == "pantheon") then true else false;

      displayManager = lib.mkIf (hostname != "soyo") {
        sessionCommands = ''
          ${pkgs.numlockx}/bin/numlockx on
        '';
      };
      # videoDrivers = [
      # "fbdev" # The fbdev (Framebuffer Device) driver is a generic framebuffer driver that provides access to the frame buffer of the display hardware.
      # "modesetting"     # The modesetting driver is a generic driver for modern video hardware that relies on kernel modesetting (KMS) to set the display modes and manage resolution and refresh rate.
      # "amdgpu"          # This is the open-source kernel driver for AMD graphics cards. It's part of the AMDGPU driver stack and provides support for newer AMD GPUs.
      # "nouveau"         # Nouveau is an open-source driver for NVIDIA graphics cards. It aims to provide support for NVIDIA GPUs and is an alternative to the proprietary NVIDIA driver
      # "radeon"          # The Radeon driver is an open-source driver for AMD Radeon graphics cards. It provides support for older AMD GPUs.
      # "nvidia"
      # ];
    };
    samba = {
      enable =
        if (hostname != "rasp3")
        then true
        else false;
      #package = pkgs.unstable.samba4Full; # samba4Full broken
      # securityType = "user";
      # openFirewall = true;
      extraConfig = ''
        client min protocol = NT1
      '';
      ### --------------------------------------------------------- ###
      #   shares = {
      #     home = {
      #       path = "/home/${username}";
      #       browseable = "yes";
      #       writeable = "yes";
      #       "acl allow execute always" = true;
      #       "read only" = "no";
      #       "valid users" = "${username}";
      #       "create mask" = "0644";
      #       "directory mask" = "0755";
      #       "force user" = "${username}";
      #       "force group" = "users";
      #     };
      #     #### ----------------------------------------------------- ####
      #     media = {
      #       path = "/run/media/${username}";
      #       browseable = "yes";
      #       writeable = "yes";
      #       "acl allow execute always" = true;
      #       "read only" = "no";
      #       "valid users" = "${username}";
      #       "create mask" = "0644";
      #       "directory mask" = "0755";
      #       "force user" = "${username}";
      #       "force group" = "users";
      #     };
      #   };
    };
    gvfs = {
      package = pkgs.unstable.gvfs;
      enable = true;
    };

    clight = {
      enable = if (hostname == "anubis") then true else false; #  notVM;
      settings = {
        verbose = true;
        backlight.disabled = false;
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
      if (hostname != "rasp3" || "soyo")
      then {
        packages = with pkgs; [ gnome.gnome-settings-daemon ];
        extraRules = ''
          # add my android device to adbusers
          SUBSYSTEM=="usb", ATTR{idVendor}=="22d9", MODE="0666", GROUP="adbusers"
        '';
      }
      else "";

    flatpak = lib.mkIf (isInstall) {
      enable = true;
    };

    pipewire = lib.mkIf (hostname != "soyo") {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = isGamestation;
      jack.enable = false;
      pulse.enable = true;
      wireplumber = {
        enable = true;
      };
    };

    printing = lib.mkIf (isInstall) {
      enable = true;
      drivers = with pkgs; [ gutenprint hplip ];
    };
    system-config-printer.enable = isInstall;
  };


  hardware = {
    # smooth backlight control
    brillo.enable =
      if hostname == "air"
      then true
      else false;
    opengl = {
      driSupport = true;
      driSupport32Bit = if (hostname == "nitro") then true else false;
      extraPackages =
        lib.mkIf (hostname == "nitro") (with pkgs; [
          intel-media-driver
          # nvidia-vaapi-driver
          libvdpau
          libvdpau-va-gl
        ]);
      extraPackages32 =
        lib.mkIf (hostname == "nitro")
          (with pkgs.pkgsi686Linux;
          [
            # intel-media-driver
            #  vaapiIntel
            vaapiVdpau
            libvdpau-va-gl
            #  libva
          ]);
    };

    # openrazer = lib.mkIf (hasRazerPeripherals) {
    #   enable = true;
    #   devicesOffOnScreensaver = false;
    #   keyStatistics = true;
    #   mouseBatteryNotifier = true;
    #   syncEffectsEnabled = true;
    #   users = [ "${username}" ];
    # };

    pulseaudio.enable = if (hostname == "soyo") then true else false;
    sane = lib.mkIf (isInstall) {
      enable = true;
      #extraBackends = with pkgs; [ hplipWithPlugin sane-airscan ];
      extraBackends = with pkgs; [ sane-airscan ];
    };
  };

  security = {
    # Allow members of the "audio" group to set RT priorities
    # Inspired by musnix: https://github.com/musnix/musnix/blob/master/modules/base.nix#L87
    pam.loginLimits = [
      { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
      { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
      { domain = "@audio"; item = "nofile"; type = "soft"; value = "99999"; }
      { domain = "@audio"; item = "nofile"; type = "hard"; value = "524288"; }
    ];

    # userland niceness
    rtkit.enable = true;
  };

  systemd = {
    services = {
      configure-flathub-repo = lib.mkIf (isInstall) {
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.flatpak ];
        script = ''
          flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        '';
      };
      configure-appcenter-repo = lib.mkIf (isInstall && desktop == "pantheon") {
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.flatpak ];
        script = ''
          flatpak remote-add --if-not-exists appcenter https://flatpak.elementary.io/repo.flatpakrepo
        '';
      };
      disable-wifi-powersave = lib.mkIf (!saveBattery) {
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.iw ];
        script = ''
          iw dev wlan0 set power_save off
        '';
      };
    };
  };

  xdg.portal = mkDefault {
    config = {
      common = {
        default = [
          "gtk"
        ];
      };
    };
    enable = true;
    xdgOpenUsePortal = true;
  };

  fonts =
    let
      lotsOfFonts = true;
    in
    {
      # Enable a basic set of fonts providing several font styles and families and reasonable coverage of Unicode.
      enableDefaultPackages = false;
      fontDir.enable = true;
      packages =
        lib.attrValues
          {
            # inherit (inputs.self.packages.${pkgs.system}) sarasa-gothic iosevka-q;
            # inherit (pkgs) material-design-icons noto-fonts-emoji symbola;
            # nerdfonts = pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; };
          } ++
        (with pkgs; [
          (nerdfonts.override { fonts = [ "FiraCode" "NerdFontsSymbolsOnly" ]; })
          fira
          liberation_ttf
          # noto-fonts-emoji
          source-serif
          inter
          roboto
          # twitter-color-emoji
          work-sans
        ] ++ lib.optionals (isInstall) [
          ubuntu_font_family
        ] ++ lib.optionals lotsOfFonts [
          # Japanese
          # ipafont # display jap symbols like シートベルツ in polybar
          # kochi-substitute

          # Code/monospace and nsymbol fonts
          fira-code
          # fira-code-symbols
          # mplus-outline-fonts.osdnRelease
          # dejavu_fonts
          # iosevka-bin
        ]);

      fontconfig = {
        antialias = true;
        cache32Bit = isGamestation;
        defaultFonts = {
          serif = [ "Source Serif" ];
          # serif = [
          # "SF Pro"
          # "Sarasa Gothic J"
          # "Sarasa Gothic K"
          # "Sarasa Gothic SC"
          # "Sarasa Gothic TC"
          # "Sarasa Gothic HC"
          # "Sarasa Gothic CL"
          # "Symbola"
          # ];
          sansSerif = [ "Inter" "Work Sans" "Fira Sans" ];
          # sansSerif = [
          #   "SF Pro"
          #   "Sarasa Gothic J"
          #   "Sarasa Gothic K"
          #   "Sarasa Gothic SC"
          #   "Sarasa Gothic TC"
          #   "Sarasa Gothic HC"
          #   "Sarasa Gothic CL"
          #   "Symbola"
          # ];
          # monospace = ["FiraCode Nerd Font Mono" "SauceCodePro Nerd Font Mono"];
          # monospace = [
          #   "SF Pro Rounded"
          #   "Sarasa Mono J"
          #   "Sarasa Mono K"
          #   "Sarasa Mono SC"
          #   "Sarasa Mono TC"
          #   "Sarasa Mono HC"
          #   "Sarasa Mono CL"
          #   "Symbola"
          # ];
          # emoji = [
          #   "Noto Color Emoji"
          #   "Material Design Icons"
          #   "Symbola"
          # ];
          monospace = [ "FiraCode Nerd Font Mono" "Symbols Nerd Font Mono" ];
          emoji = [ "Noto Color Emoji" "Twitter Color Emoji" ];
        };
        enable = true;
        hinting = {
          autohint = false;
          enable = true;
          style = "slight";
        };
        subpixel = {
          rgba = "rgb";
          lcdfilter = "light";
        };
      };

      # # Lucida -> iosevka as no free Lucida font available and it's used widely
      fontconfig.localConf = lib.mkIf lotsOfFonts ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <match target="pattern">
            <test name="family" qual="any"><string>Lucida</string></test>
            <edit name="family" mode="assign">
              <string>iosevka</string>
            </edit>
          </match>
        </fontconfig>
      '';
    };
}
