{ config, lib, inputs, pkgs, ... }:
let
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];
  boot = {
    blacklistedKernelModules = [ "nouveau" ]; # blacklist nouveau module so that it does not conflict with nvidia drm stuff
    ### Default Kernel
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    # kernelPackages = pkgs.linuxPackages_zen;
    # kernelPackages = pkgs.linuxPackages_lqx;
    kernelModules = [
      "kvm-intel"
      "z3fold"
      "lz4hc"
      "lz4hc_compress"
    ];
    kernelParams = [
      "usbcore.autosuspend=-1" # Disable USB autosuspend
      "zswap.enabled=1"
      "mem_sleep_default=deep"
    ];
    kernel = {
      sysctl = {
        "net.core.netdev_max_backlog" =
          30000; # Help prevent packet loss during high traffic periods.
        "net.core.rmem_max" =
          33554432; # Maximum socket receive buffer size, determine the amount of data that can be buffered in memory for network operations. Adjusted for 16GB RAM.
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
    initrd = {
      availableKernelModules = [
        "xhci_pci" # USB 3.0
        "ahci" # SATA devices on modern AHCI controllers
        "nvme"
        "usb_storage" # USB mass storage devices
        "usbhid" # USB human interface devices
        "sd_mod" # SCSI, SATA, and IDE devices
        "rtsx_pci_sdmmc"
        "aesni_intel"
        "cryptd"
      ];
      systemd.enable = true;
      compressor = "zstd";
      compressorArgs = [ "-19" "-T0" ];
      verbose = lib.mkForce false;
    };
    loader = {
      efi = {
        efiSysMountPoint = lib.mkForce "/boot/efi";
      };
      grub = {
        theme = pkgs.catppuccin-grub;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
      };
    };
  };

  # enable secondary monitors at boot time
  specialisation = {
    full-nvidia.configuration = {
      system.nixos.tags = [ "full-nvidia" ];
      boot = {
        kernelModules = lib.mkForce [
          "clearcpuid=514" # Fixes certain wine games crash on launch
          "nvidia"
          "nvidia_modeset"
          "nvidia_uvm"
          "nvidia_drm"
        ];
        kernelParams = [
          "nvidia.NVreg_PreserveVideoMemoryAllocations=1" # To save and restore all video memory contents
          "nvidia.NVreg_UsePageAttributeTable=1" # Enable the PAT feature
          "nvidia.NVreg_RegistryDwords='OverrideMaxPerf=0x1'"
        ];
        kernel.sysctl = lib.mkForce {
          "vm.max_map_count" = 2147483642;
        };
      };
      hardware = {
        nvidia = {
          prime.offload.enable = lib.mkForce false;
          powerManagement = {
            enable = lib.mkForce false;
            finegrained = lib.mkForce false;
          };
          forceFullCompositionPipeline = true;

          # Modesetting is needed for most Wayland compositors
          modesetting.enable = true;
          nvidiaSettings = false; # add nvidia-settings to pkgs, useless on nixos
        };
      };
    };
    external-display-only.configuration = {
      system.nixos.tags = [ "ext-display-only" ];
      boot.kernelParams = [ "video=eDP-1:d" "video=LVDS-1:d" ];
    };
    # headless.configuration = {
    #   system.nixos.tags = [ "headless" ];

    #   # environment.noXlibs = lib.mkForce true; # remove all x11

    #   # Disable the X11 windowing system
    #   services.xserver.enable = lib.mkForce false;

    #   # Disable the GNOME Desktop Environment
    #   services.xserver.displayManager.gdm.enable = lib.mkForce false;
    #   services.xserver.desktopManager.gnome.enable = lib.mkForce false;
    # };
  };

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    opengl = {
      enable = true;
      driSupport = true;
    };

    nvidia = {
      package =
        let
          nPkgs = config.boot.kernelPackages.nvidiaPackages;
        in
        lib.mkForce (if (lib.versionOlder nPkgs.beta.version nPkgs.stable.version) then nPkgs.stable else nPkgs.beta);

      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";

        offload.enable = lib.mkDefault true;
        offload.enableOffloadCmd = lib.mkDefault true;

        # Make the Intel iGPU default; the NVIDIA is for CUDA/NVENC
        ## With Reverse Prime the primary rendering device is the device's APU and the
        ## NVIDIA GPU acts as an offload device. This is done while also allowing to use
        ## the video outputs connected to the NVIDIA device. Additionally, this might use
        ## less power than Prime Sync since the more power efficient APU does most of the
        ## rendering, thus, allowing the NVIDIA card to sleep where possible.
        reverseSync.enable = true;


        # sync.enable = lib.mkDefault false;
      };


      powerManagement = {
        enable = true; # enable systemd-based graphical suspend to prevent black screen on resume
        finegrained = true; # power down GPU when no applications are running that require nvidia
      };
    };

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libva
        libva-utils
        vaapiVdpau
        vulkan-loader
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [ nvidia-vaapi-driver ];
    };
  };

  environment.systemPackages =
    let
      nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-GO
        export __GLX_VENDOR_LIBRARY_NAME=nvidia::
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec "$@"
      '';
    in
    [ nvidia-offload ];

  services = {
    xserver = {
      videoDrivers = [
        "i915"
        "nvidia"
      ];
    };
  };
}
