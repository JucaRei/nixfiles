{ config
, lib
, pkgs
, inputs
, ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-hdd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ../../_mixins/hardware/sound/pipewire.nix
    ../../_mixins/hardware/graphics/nvidia/nvidia-offload.nix
    # ../../_mixins/hardware/graphics/nvidia/nvidia-specialisation.nix
    # ../../_mixins/hardware/graphics/intel/intel-gpu-dual.nix
    ../../_mixins/hardware/bluetooth
    ../../_mixins/hardware/boot/grub.nix
    ../../_mixins/hardware/cpu/intel-cpu.nix
    ../../_mixins/hardware/power/tlp.nix
    ../../_mixins/hardware/other/usb.nix
    # ../../_mixins/virtualization/quickemu.nix
    ../../_mixins/virtualization/podman.nix
    ../../_mixins/services/security/sudo.nix
    # ../../_mixins/virtualization/k8s.nix
    ../../_mixins/virtualization/virt-manager.nix
    ../../_mixins/sys/ananicy.nix
    ../../_mixins/sys/psd.nix
    ../../_mixins/sys/dbus-broker.nix
    ../../_mixins/sys/irqbalance.nix
    ../../_mixins/sys/fwupd.nix
    ../../_mixins/sys/thermald.nix
    #../../_mixins/virtualization/gpu_isolate.nix
    # ../../_mixins/apps/text-editor/vscode.nix
    # ../../_mixins/apps/browser/firefox.nix
    # ../../_mixins/apps/browser/chromium.nix
    # ../../_mixins/console/fish.nix
  ];
  boot = {
    # extraModprobeConfig = ''
    #   options vfio-pci ids=10de:1c8d,10de:0fb9 softdep nvidia pre: vfio-pci
    # '';
    # postBootCommands = ''
    # DEVS="0000:01:00.0 0000:01:00.1"

    # for DEV in $DEVS; do
    #   echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
    # done
    # modprobe -i vfio-pci
    # '';
    loader = {
      # generationsDir.copyKernels = true;  ## Copy kernel files into /boot so /nix/store isn't needed
      grub = {
        # theme = pkgs.cyberre-grub-theme;
        theme = pkgs.catppuccin-grub;
        ## Copy kernels to /boot
        # copyKernels = true;

        ## mirror boot partitions
        # mirroredBoots = [
        #   {
        #     devices = [ "nodev" ];
        #     path = "/boot/efis/EFIBOOT0";
        #     efiSysMountPoint = "/boot/efis/EFIBOOT0";
        #   }
        #   {
        #     devices = [ "nodev" ];
        #     path = "/boot/efis/EFIBOOT1";
        #     efiSysMountPoint = "/boot/efis/EFIBOOT1";
        #   }
        # ];
      };
    };
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      kernelModules = [ ];
      verbose = lib.mkForce false;
    };
    consoleLogLevel = lib.mkForce 0;
    tmp = {
      # useTmpfs = true;
      cleanOnBoot = true;
    };
    supportedFilesystems = [ "vfat" "btrfs" ];

    kernelModules = [
      "kvm-intel"
      #"i915"
      "z3fold"
      #"hdapsd"
      "crc32c-intel"
      "lz4hc"
      "lz4hc_compress"
      # "vhost_vsock"
      # The 'splash' arg is included by the plymouth option
      # "boot.shell_on_fail"
    ];
    # plymouth = {
    # enable = true;
    # logo = "${inputs.nixos-artwork}/wallpapers/nix-wallpaper-watersplash.png";
    # themePackages = [
    # pkgs.adi1090x-plymouth-themes
    # pkgs.catppuccin-plymouth
    # ];
    # theme = "deus_ex";
    # theme = "catppuccin-macchiato";
    # };
    plymouth = rec {
      enable = true;
      # black_hud circle_hud cross_hud square_hud
      # circuit connect cuts_alt seal_2 seal_3
      theme = "connect";
      themePackages = with pkgs; [
        (
          adi1090x-plymouth-themes.override {
            selected_themes = [ theme ];
          }
        )
      ];
    };

    # Temporary workaround until mwprocapture 4328 patch is merged
    # - https://github.com/NixOS/nixpkgs/pull/221209
    # kernelPackages = pkgs.linuxPackages_zen;
    # kernelPackages = pkgs.linuxPackages_lqx;
    kernelPackages = pkgs.linuxPackages_xanmod_stable;

    kernelParams = lib.mkForce [
      "quiet"
      "usbcore.autosuspend=-1" # Disable usb autosuspend
      "rd.plymouth=0"
      "plymouth.enable=0"
      "log-level=0"
      "systemd.log_level=0"
      "systemd.show_status=0"
      "mitigations=off"
      "zswap.enabled=1"
      "zswap.compressor=lz4hc"
      "zswap.max_pool_percent=20"
      "zswap.zpool=z3fold"
      "mem_sleep_default=deep"
    ];
    kernel.sysctl = lib.mkForce {
      "net.ipv4.ip_unprivileged_port_start" = 80; # Podman access port 80
      #---------------------------------------------------------------------
      #   Network and memory-related optimizationss for desktop 16GB
      #---------------------------------------------------------------------
      "kernel.sysrq" =
        1; # Enable SysRQ for rebooting the machine properly if it freezes. [Source](https://oglo.dev/tutorials/sysrq/index.html)
      "net.core.netdev_max_backlog" =
        30000; # Help prevent packet loss during high traffic periods.
      "net.core.rmem_default" =
        262144; # Default socket receive buffer size, improve network performance & applications that use sockets. Adjusted for 16GB RAM.
      "net.core.rmem_max" =
        33554432; # Maximum socket receive buffer size, determine the amount of data that can be buffered in memory for network operations. Adjusted for 16GB RAM.
      "net.core.wmem_default" =
        262144; # Default socket send buffer size, improve network performance & applications that use sockets. Adjusted for 16GB RAM.
      "net.core.wmem_max" =
        33554432; # Maximum socket send buffer size, determine the amount of data that can be buffered in memory for network operations. Adjusted for 16GB RAM.
      "net.ipv4.ipfrag_high_threshold" =
        5242880; # Reduce the chances of fragmentation. Adjusted for SSD.
      "net.ipv4.tcp_keepalive_intvl" =
        30; # TCP keepalive interval between probes to detect if a connection is still alive.
      "net.ipv4.tcp_keepalive_probes" =
        5; # TCP keepalive probes to detect if a connection is still alive.
      "net.ipv4.tcp_keepalive_time" =
        300; # TCP keepalive interval in seconds to detect if a connection is still alive.
      "vm.dirty_background_bytes" = 134217728; # 128 MB
      "vm.dirty_bytes" = 402653184; # 384 MB
      "vm.min_free_kbytes" =
        65536; # Minimum free memory for safety (in KB), helping prevent memory exhaustion situations. Adjusted for 16GB RAM.
      "vm.swappiness" =
        20; # Adjust how aggressively the kernel swaps data from RAM to disk. Lower values prioritize keeping data in RAM. Adjusted for 16GB RAM. 10
      "vm.vfs_cache_pressure" =
        90; # Adjust vfs_cache_pressure (0-1000) to manage memory used for caching filesystem objects. Adjusted for 16GB RAM.
      # With zstd, the decompression is so slow
      # that that there's essentially zero throughput gain from readahead.
      # Prevents uncompressing any more than you absolutely have to,
      # with a minimal reduction to sequential throughput
      "vm.page-cluster" = 0;

      # Nobara Tweaks
      "fs.aio-max-nr" =
        1000000; # defines the maximum number of asynchronous I/O requests that can be in progress at a given time.     1048576
      "fs.inotify.max_user_watches" =
        65536; # sets the maximum number of file system watches, enhancing file system monitoring capabilities.       Default: 8192  TWEAKED: 524288
      "kernel.panic" =
        5; # Reboot after 5 seconds on kernel panic                                                               Default: 0
      "kernel.pid_max" =
        131072; # allows a large number of processes and threads to be managed                                         Default: 32768 TWEAKED: 4194304
      #---------------------------------------------------------------------
      #   SSD tweaks: Adjust settings for an SSD to optimize performance.
      #---------------------------------------------------------------------
      "vm.dirty_background_ratio" = "40"; # Set the ratio of dirty memory at which background writeback starts (5%). Adjusted for SSD.
      "vm.dirty_expire_centisecs" = "3000"; # Set the time at which dirty data is old enough to be eligible for writeout (6000 centiseconds). Adjusted for SSD.
      "vm.dirty_ratio" = "80"; # Set the ratio of dirty memory at which a process is forced to write out dirty data (10%). Adjusted for SSD.
      "vm.dirty_time" = "0"; # Disable dirty time accounting.
      "vm.dirty_writeback_centisecs" = "300"; # Set the interval between two consecutive background writeback passes (500 centiseconds).

      ## TCP hardening
      # Prevent bogus ICMP errors from filling up logs.
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      # Reverse path filtering causes the kernel to do source validation of
      # packets received from all interfaces. This can mitigate IP spoofing.
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      # Do not accept IP source route packets (we're not a router)
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      # Don't send ICMP redirects (again, we're on a router)
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      # Refuse ICMP redirects (MITM mitigations)
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      # Protects against SYN flood attacks
      "net.ipv4.tcp_syncookies" = 1;
      # Incomplete protection again TIME-WAIT assassination
      "net.ipv4.tcp_rfc1337" = 1;

      ## TCP optimization
      # TCP Fast Open is a TCP extension that reduces network latency by packing
      # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
      # both incoming and outgoing connections:
      "net.ipv4.tcp_fastopen" = 3;
      # Bufferbloat mitigations + slight improvement in throughput & latency
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "cake";
    };
  };

  ### For services ###
  location = {
    provider = "manual";
    latitude = -23.53938;
    longitude = -46.65253;
  };

  ##################
  ### FILESYSTEM ###
  ##################

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/Nitroux";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs";
      options = [
        "subvol=@rootfs"
        "rw"
        "noatime"
        "nodiratime"
        "ssd"
        "compress-force=zstd:15"
        "space_cache=v2"
        "nodatacow"
        "commit=120"
        "discard=async"
        "x-gvfs-hide" # hide from filemanager
      ];
    };

    "/home" = {
      device = "/dev/disk/by-label/Nitroux";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs";
      options = [
        "subvol=@home"
        "rw"
        "noatime"
        "nodiratime"
        "ssd"
        "compress-force=zstd:15"
        "space_cache=v2"
        "commit=120"
        "discard=async"
      ];
    };

    "/.snapshots" = {
      device = "/dev/disk/by-label/Nitroux";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs";
      options = [
        "subvol=@snapshots"
        "rw"
        "noatime"
        "nodiratime"
        "ssd"
        "nodatacow"
        "compress-force=zstd:15"
        "space_cache=v2"
        "commit=120"
        "discard=async"
      ];
    };

    "/var/tmp" = {
      device = "/dev/disk/by-label/Nitroux";
      fsType = "btrfs";
      options = [
        "subvol=@tmp"
        "rw"
        "noatime"
        "nodiratime"
        "nodatacow"
        "ssd"
        "compress-force=zstd:15"
        "space_cache=v2"
        "commit=120"
        "discard=async"
      ];
    };

    "/var/log" = {
      device = "/dev/disk/by-label/Nitroux";
      fsType = "btrfs";
      options = [
        "subvol=@logs"
        "rw"
        "noatime"
        "nodiratime"
        "ssd"
        "compress-force=zstd:15"
        "space_cache=v2"
        "commit=120"
        "discard=async"
      ];
    };

    "/var/swap" = {
      device = "/dev/disk/by-label/Nitroux";
      fsType = "btrfs";
      options = [
        "subvol=@swap"
        "defaults"
        "noatime"
      ];
    };

    "/nix" = {
      device = "/dev/disk/by-label/Nitroux";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs";
      options = [
        "subvol=@nix"
        "rw"
        "noatime"
        "nodiratime"
        "ssd"
        "compress-force=zstd:15"
        "space_cache=v2"
        "commit=120"
        "discard=async"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "ext4";
    };

    "/boot/efi" = {
      device = "/dev/disk/by-label/EFI";
      # device = "/dev/disk/by-uuid/076D-BEC9";
      fsType = "vfat";
      options = [
        "defaults"
        "noatime"
        "nodiratime"
        "x-gvfs-hide" # hide from filemanager
      ];
      noCheck = true;
    };
  };

  swapDevices = [
    {
      device = "/var/swap/swapfile";
      # size = "20G";
    }
  ];

  # zramSwap = {
  #   enable = true;
  #   swapDevices = 1;
  #   memoryPercent = 150;
  # };

  # # This allows you to dynamically switch between NVIDIA<->Intel using
  # # nvidia-offload script
  # specialisation = {
  #   nvidia-offload.configuration = {
  #     hardware.nvidia = {
  #       prime = {
  #         offload.enable = lib.mkForce true;
  #         sync.enable = lib.mkForce false;
  #       };
  #       modesetting.enable = lib.mkForce false;
  #     };
  #     system.nixos.tags = [ "nvidia-offload" ];
  #   };
  # };

  hardware = {
    cpu.intel.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;

    # nvidia = {
    #   package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.production;
    #   prime = {
    #     intelBusId = "PCI:0:2:0";
    #     nvidiaBusId = "PCI:1:0:0";
    # Make the intel igpu default. The NVIDIA is for CUDA/NVENC
    # reverseSync.enable = true;

    # sync.enable = true;
    # };
    # nvidiaSettings = false;
    # forceFullCompositionPipeline = true;
    # };
  };

  nixpkgs = {
    # config.packageOverrides = pkgs: {
    #   vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    # };

    hostPlatform = lib.mkDefault "x86_64-linux";
  };

  environment = {
    systemPackages = with pkgs; [
      btdu
      btrfs-progs
      compsize
      cloneit
      # unstable.stacer
      lm_sensors
      #thorium
    ];
    sessionVariables = {
      # LIBVA_DRIVER_NAME = "nvidia";
      #  # maybe causes firefox crashed?
      #  GBM_BACKEND = "nvidia-drm";
      #  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      #  WLR_NO_HARDWARE_CURSORS = "1";
    };

    # etc = {
    #   "systemd/system-sleep/batenergy".source = pkgs.writeShellScript "batenergy" ''
    #     PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.bc ]}
    #     source ${pkgs.fetchFromGitHub {
    #       owner = "equaeghe";
    #       repo = "batenergy";
    #       rev = "13c381f68f198af361c5bd682b32577131fbb60f";
    #       hash = "sha256-4JQrSD8HuBDPbBGy2b/uzDvrBUZ8+L9lAnK95rLqASk=";
    #     }}/batenergy.sh "$@"
    #   '';
    # };
  };

  services = {
    dbus.implementation = lib.mkForce "broker";
    acpid = { enable = true; };
    power-profiles-daemon.enable = lib.mkDefault true;
    # upower.enable = true;
    # udev.extraRules = lib.mkMerge [
    # ''ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"'' # autosuspend USB devices
    # ''ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"'' # autosuspend PCI devices
    # ''ACTION=="add", SUBSYSTEM=="net", NAME=="enp*", RUN+="${pkgs.ethtool}/sbin/ethtool -s $name wol d"'' # disable Ethernet Wake-on-LAN
    # ];
    btrfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
    };
    # xserver = {
    # videoDrivers = [ "i915" ];
    # displayManager.sessionCommands = ''
    #   ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 1 0
    #   ${pkgs.xorg.xrandr}/bin/xrandr --auto
    # '';
    #######################
    ### Xserver configs ###
    #######################
    # layout = lib.mkForce "br";
    # xkbVariant = "abnt2";
    # xkbModel = lib.mkForce "pc105";
    # xkbOptions = "grp:alt_shift_toggle";
    # libinput = {
    #   enable = true;
    #   touchpad = {
    #     # horizontalScrolling = true;
    #     # tappingDragLock = false;
    #     tapping = true;
    #     naturalScrolling = false;
    #     scrollMethod = "twofinger";
    #     disableWhileTyping = true;
    #     sendEventsMode = "disabled-on-external-mouse";
    #     # clickMethod = "clickfinger";
    #   };
    #   mouse = {
    #     naturalScrolling = false;
    #     disableWhileTyping = true;
    #     accelProfile = "flat";
    #   };
    # };
    # xrandrHeads = [
    #   {
    #     output = "HDMI-1-0";
    #     primary = true;
    #     monitorConfig = ''
    #       Modeline "1920x1080_60.00"
    #     '';
    #   }
    #   {
    #     output = "eDP";
    #     primary = false;
    #     monitorConfig = ''
    #       Option "PreferredMode" "1920x1080"
    #       Option "Position" "0 0"
    #     '';
    #   }
    # ];
    # exportConfiguration = true;
    # };
    # power-profiles-daemon.enable = lib.mkForce false;
    # tlp = {
    #   enable = true;
    #   settings = lib.mkDefault {
    #     PCIE_ASPM_ON_BAT = "powersupersave";
    #     RUNTIME_PM_ON_AC = "auto";
    #     # Operation mode when no power supply can be detected: AC, BAT.
    #     TLP_DEFAULT_MODE = "BAT";
    #     # Operation mode select: 0=depend on power source, 1=always use TLP_DEFAULT_MODE
    #     TLP_PERSISTENT_DEFAULT = "1";
    #     DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
    #     DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "wwan";
    #     DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "wifi";
    #   };
    # };

    # Early OOM Killer
    earlyoom = {
      enable = true; # Enable the early OOM (Out Of Memory) killer service.

      # Free Memory Threshold
      # Sets the point at which earlyoom will intervene to free up memory.

      # When free memory falls below 15%, earlyoom acts to prevent system slowdown or freezing.
      freeSwapThreshold = 2;
      freeMemThreshold = 2;
      extraArgs = [
        "-g"
        "--avoid '^(X|plasma.*|konsole|kwin|foot)$'"
        "--prefer '^(electron|libreoffice|gimp)$'"
      ];

      # Technical Explanation:
      # The earlyoom service monitors system memory and intervenes when free memory drops below the specified threshold.
      # It helps prevent system slowdowns and freezes by intelligently killing less important processes to free up memory.
      # In this configuration, it triggers when free memory is only 15% of total RAM.
      # Adjust the freeMemThreshold value based on your system's memory usage patterns.

      # source:   https://github.com/rfjakob/earlyoom
    };

    #---------------------------------------------------------------------
    # Provides a virtual file system for environment modules. Solution
    # from NixOS forums to help shotwell to keep preference settings
    #---------------------------------------------------------------------
    envfs = { enable = true; };

    #---------------------------------------------------------------------
    # Activate the automatic trimming process for SSDs on the NixOS system
    # Manual over-ride is sudo fstrim / -v
    #---------------------------------------------------------------------
    fstrim = { enable = true; };
  };

  ### Load z3fold and lz4

  systemd = {
    oomd = { enable = false; };
    services = {
      zswap = {
        description = "Enable ZSwap, set to LZ4 and Z3FOLD";
        enable = true;
        wantedBy = [ "basic.target" ];
        path = [ pkgs.bash ];
        serviceConfig = {
          ExecStart = ''
            ${pkgs.bash}/bin/bash -c 'cd /sys/module/zswap/parameters&& \
                  echo 1 > enabled&& \
                  echo 20 > max_pool_percent&& \
                  echo lz4hc > compressor&& \
                  echo z3fold > zpool'
          '';
          Type = "simple";
        };
      };

      nix-daemon = {
        ### Limit resources used by nix-daemon
        serviceConfig = {
          MemoryMax = "8G";
          MemorySwapMax = "12G";
        };
      };
    };

    sleep.extraConfig = ''
      AllowHibernation=no
      AllowSuspend=yes
      AllowSuspendThenHibernate=no
      AllowHybridSleep=no
    '';
  };
  #specialisation."VM-passthrough".configuration = {
  #  system.nixos.tags = [ "VM-passthrough" ];
  #  boot.loader.grub.configurationName = lib.mkOverride 40 "Pass-through Nvidia";
  #  vfio.enable = false;
  #};

  nix.settings = {
    extra-substituters = [ "https://nitro.cachix.org" ];
    extra-trusted-public-keys = [ "nitro.cachix.org-1:Z4AoDBOqfAdBlAGBCoyEZuwIQI9pY+e4amZwP94RU0U=" ];
  };
}
