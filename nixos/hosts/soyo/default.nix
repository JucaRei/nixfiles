{ config, lib, pkgs, modulesPath, username, ... }: {
  imports = [
    ../../_mixins/hardware/boot/efi.nix
    ../../_mixins/hardware/other/usb.nix
    ../../_mixins/services/security/sudo.nix
  ];

  config = {
    boot = {
      mode.efi.enable = true;
      loader = {
        efi = {
          efiSysMountPoint = lib.mkForce "/boot/efi";
        };
        grub = {
          theme = pkgs.cyberre-grub-theme;
        };
      };
      initrd = {
        availableKernelModules = [
          "ahci" # Enables the Advanced Host Controller Interface (AHCI) driver, typically used for SATA (Serial ATA) controllers.
          "xhci_pci" # Enables the eXtensible Host Controller Interface (xHCI) driver for PCI-based USB controllers, providing support for USB 3.0 and later standards.
          "usbhid" # module is very simple, it takes no parameters, detects everything automatically and when a HID device is inserted, it detects it appropriately.
          "usb_storage"
          "sd_mod"
          "uas"
          "sdhci_pci"
        ];
        kernelModules = [ ];
        systemd.enable = true;
        compressor = "zstd";
        compressorArgs = [ "-19" "-T0" ];
        verbose = lib.mkForce false;
      };
      consoleLogLevel = lib.mkForce 0;
      tmp = {
        # useTmpfs = true;
        cleanOnBoot = true;
      };
      kernelModules = [
        "kvm-intel" # KVM on Intel CPUs
        "coretemp" # Temperature monitoring on Intel CPUs
        "fuse" # userspace filesystem framework.
        "i2c-dev" # An acronym for the “Inter-IC” bus, a simple bus protocol which is widely used where low data rate communications suffice.
        "tcp_bbr" # BBR: Dynamically optimize how data is sent over a network, aiming for higher throughput and reduced latency
        "tcp_cubic" # Cubic: A traditional and widely used congestion control algorithm
        "tcp_westwood" # Westwood: Particularly effective in wireless networks
        "crc32c-intel"
        # "z3fold"
        # "lz4hc"
        # "lz4hc_compress"
      ];
      kernelParams = [
        # intel cpu
        "i915.fastboot=1"
        "enable_gvt=1"
        "mem_sleep_default=deep"

        "elevator=kyber" # Change IO scheduler to Kyber
        "fbcon=nodefer" # Prevent the kernel from blanking plymouth out of the framebuffer
        "intel_iommu=on" # Enable IOMMU
        "io_delay=none" # Disable I/O delay accounting
        "iomem=relaxed" # Allow more relaxed I/O memory access
        "iommu=pt" # Enables passthrough mode for the IOMMU, allowing direct access to hardware devices
        "irqaffinity=0-7" # Set IRQ affinity to CPUs 0-7
        "loglevel=3" # Set kernel log level to 3 (default)
        # "logo.nologo" # Disable boot logo if any
        "mitigations=off" # Turn off certain CPU security mitigations. It might enhance performance
        "nmi-watchdog=0" # Disable the non-maskable interrupt (NMI) watchdog
        "noirqdebug" # Disable IRQ debugging
        "rootdelay=0" # No delay when mounting root filesystem
        "threadirqs" # Enable threaded interrupt handling
        "video.allow_duplicates=1" # Allow duplicate frames or similar, helps smooth video playback
        "zswap.max_pool_percent=10" # Set zswap maximum pool percentage to 10%
        "zswap.compressor=lz4" # Set zswap compressor to lz4
        "zswap.enabled=1" # Enable zswap
        "zswap.zpool=zsmalloc" # Set zswap zpool to zsmalloc
      ];
      kernel = {
        sysctl = lib.mkForce {
          "vt.cur_default" = "0x700010";
          "net.ipv4.ip_forward" = 1;
          "net.ipv6.conf.all.forwarding" = 1;
          "vm.page-cluster" = 1; # Keep zram swap (lz4) latency in check

          # Kernel Settings
          "kernel.pty.max" = 24000; # Maximum number of pseudo-terminal (pty) devices.
          "kernel.sched_autogroup_enabled" = 0; # Disable automatic grouping of tasks in the scheduler.
          "kernel.sched_migration_cost_ns" = 5000000; # Cost (in nanoseconds) of migrating a task to another CPU.
          "kernel.sysrq" = 1; # Enable the SysRq key for low-level system commands.
          "kernel.pid_max" = 131072; # Maximum number of processes and threads.
          "net.ipv4.ip_unprivileged_port_start" = 80; # Podman access port 80

          # Network Settings
          # "net.core.default_qdisc" = "fq"; # Use Fair Queueing (FQ) as default queuing discipline for reduced latency.
          "net.core.default_qdisc" = "cake";
          "net.core.netdev_max_backlog" = 30000; # Helps prevent packet loss during high traffic periods.
          "net.core.rmem_default" = 4194304; # Default socket receive buffer size increased for better network performance.
          "net.core.rmem_max" = 16777216; # Maximum socket receive buffer size increased for better network performance.
          "net.core.wmem_default" = 4194304; # Default socket send buffer size increased for better network performance.
          "net.core.wmem_max" = 16777216; # Maximum socket send buffer size increased for better network performance.
          "net.ipv4.ipfrag_high_threshold" = 5242880; # Threshold to reduce fragmentation.
          "net.ipv4.tcp_fastopen" = 3; # Bufferbload mitigations + slight improvement in throughput & latency
          "net.ipv4.tcp_congestion_control" = "bbr"; # Use TCP BBR congestion control algorithm for optimized throughput.
          "net.ipv4.tcp_keepalive_intvl" = 15; # TCP keepalive interval in seconds for faster detection of connection issues.
          "net.ipv4.tcp_keepalive_probes" = 3; # TCP keepalive probes for faster detection of connection issues.
          "net.ipv4.tcp_keepalive_time" = 120; # TCP keepalive interval in seconds for faster detection of connection issues.
          "net.ipv4.ip_default_ttl" = 65; # Bypass hotspot restrictions for certain ISPs
          "net.ipv4.udp_rmem_min" = 16384;
          "net.ipv4.udp_wmem_min" = 16384;
          "net.ipv4.tcp_tw_reuse" = 1;
          "net.ipv4.tcp_mtu_probing" = 1;

          # Virtual Memory Settings
          "vm.dirty_background_bytes" = 67108864; # Reduce dirty background bytes to 64 MB for faster writeback initiation.
          "vm.dirty_bytes" = 268435456; # Increase dirty bytes to 256 MB for more efficient dirty memory handling.
          "vm.dirty_background_ratio" = 5; # Set very low dirty background ratio to trigger faster writeback (5%).
          "vm.dirty_expire_centisecs" = 1000; # Decrease dirty expire centiseconds to 10 seconds for faster writeout.
          "vm.dirty_ratio" = 30; # Lower dirty ratio to 30% for faster process writeout.
          "vm.dirty_time" = 1; # Enable dirty time accounting to track dirty page age.
          "vm.dirty_writeback_centisecs" = 100; # Reduce dirty writeback centiseconds to 1 second for faster background writeback.
          "vm.max_map_count" = 1000000; # Maximum number of memory map areas per process.
          "vm.min_free_kbytes" = 131072; # Minimum free memory for safety (in KB).
          "vm.swappiness" = 10; # Kernel tendency to swap inactive memory pages.
          "vm.vfs_cache_pressure" = 90; # Management of memory used for caching filesystem objects.

          # File System Settings
          "fs.aio-max-nr" = 524288; # Increase maximum number of asynchronous I/O requests for faster file I/O.
          "fs.inotify.max_user_watches" = 1048576; # Increase maximum number of file system watches for better file system monitoring.

          # Nobara Tweaks
          "kernel.panic" = 5; # Reboot after 5 seconds on kernel panic.
        };
      };
      extraModulePackages = [ ];
      blacklistedKernelModules = [ "nouveau" "nvidia" ];
    };

    # Intel GPU
    hardware = {
      opengl = {
        enable = true;
        extraPackages = with pkgs; [
          # Quick Sync Video
          # vpl-gpu-rt # or intel-media-sdk for QSV
          intel-media-sdk

          # Accelerated Video Playback
          intel-media-driver # LIBVA_DRIVER_NAME=iHD
          # intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
          vaapiIntel
          libvdpau-va-gl
        ];
      };
    };
    environment = {
      sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver
      systemPackages = with pkgs; [
        btdu
        btrfs-progs
        compsize
        cloneit
        lm_sensors
      ];
    };
    ##################
    ### FILESYSTEM ###
    ##################
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/Soyos";
        fsType = "btrfs";
        options = [
          "subvol=@rootfs"
          "rw"
          "noatime"
          "nodiratime"
          "ssd"
          "compress-force=zstd:3"
          "space_cache=v2"
          "nodatacow"
          "commit=120"
          "discard=async"
          "x-gvfs-hide" # hide from filemanager
        ];
      };
      "/home" = {
        device = "/dev/disk/by-label/Soyos";
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
        device = "/dev/disk/by-label/Soyos";
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
        device = "/dev/disk/by-label/Soyos";
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
        device = "/dev/disk/by-label/Soyos";
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
      # "/var/swap" = {
      #   device = "/dev/disk/by-label/Soyos";
      #   fsType = "btrfs";
      #   options = [
      #     "subvol=@swap"
      #     "defaults"
      #     "noatime"
      #   ];
      # };
      "/nix" = {
        device = "/dev/disk/by-label/Soyos";
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
      # "/boot" = {
      #   device = "/dev/disk/by-label/BOOT";
      #   fsType = "ext4";
      # };
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

      # Set up tmpfs for /run with a fixed size
      "/run" = {
        device = "tmpfs";
        options = [ "size=5G" ];
      };

      # Set up tmpfs for /tmp with a fixed size
      "/tmp" = {
        device = "tmpfs";
        options = [ "size=5G" ];
      };

      # Smb folders
      "/mnt/sharecenter/volume_1" = {
        device = "//192.168.1.207/volume_1";
        fsType = "cifs";
        # options = [ "guest" "x-systemd.automount" "noauto" "uid=1000" "gid=100" "vers=1.0" "nounix" "x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s" ];
        options = [ "guest" "x-systemd.automount" "noauto" "uid=1000" "vers=1.0" "nounix" "x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s" ];
      };

      "/mnt/sharecenter/volume_2" = {
        device = "//192.168.1.207/volume_2/Transmission/complete";
        fsType = "cifs";
        # options = [ "guest" "x-systemd.automount" "noauto" "uid=1000" "gid=100" "vers=1.0" "nounix" "x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s" ];
        options = [ "guest" "x-systemd.automount" "noauto" "uid=1000" "vers=1.0" "nounix" "x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s" ];
      };
    };
    swapDevices = [
      {
        device = "/dev/disk/by-label/SWAP";
        # device = "/var/swap/swapfile";
        # size = "20G";
      }
    ];
    services = {
      acpid = {
        enable = true;
      };
      # btrfs = {
      #   autoScrub = {
      #     enable = true;
      #     interval = "weekly";
      #   };
      # };
      rpcbind.enable = true; # Enable RPC bind service
      earlyoom = {
        enable = true;
        freeSwapThreshold = 2;
        freeMemThreshold = 2;
        extraArgs = [
          "-g"
          "--avoid '^(X|plasma.*|konsole|kwin|foot)$'"
          "--prefer '^(electron|libreoffice|gimp)$'"
        ];
      };
      # fstrim = { enable = true; };
    };
    systemd = {
      oomd = { enable = false; };
      services = {
        #   zswap = {
        #     description = "Enable ZSwap, set to LZ4 and Z3FOLD";
        #     enable = true;
        #     wantedBy = [ "basic.target" ];
        #     path = [ pkgs.bash ];
        #     serviceConfig = {
        #       ExecStart = ''
        #         ${pkgs.bash}/bin/bash -c 'cd /sys/module/zswap/parameters&& \
        #               echo 1 > enabled&& \
        #               echo 20 > max_pool_percent&& \
        #               echo lz4hc > compressor&& \
        #               echo z3fold > zpool'
        #       '';
        #       Type = "simple";
        #     };
        #   };
        nix-daemon = {
          ### Limit resources used by nix-daemon
          serviceConfig = {
            MemoryMax = "4G";
            MemorySwapMax = "8G";
          };
        };
      };
    };
    nixpkgs = {
      hostPlatform = lib.mkDefault "x86_64-linux";
    };
    console.keyMap = lib.mkForce "br";
    systemd.enableUnifiedCgroupHierarchy = lib.mkForce true;
  };
}
