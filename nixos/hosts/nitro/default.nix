{ config, lib, pkgs, inputs, ... }: {
  imports = [
    # inputs.nixos-hardware.nixosModules.common-cpu-intel
    # inputs.nixos-hardware.nixosModules.common-gpu-intel
    # inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-hdd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ../../_mixins/hardware/sound/pipewire.nix
    ../../_mixins/hardware/graphics/nvidia.nix
    ../../_mixins/hardware/graphics/intel-gpu-dual.nix
    ../../_mixins/hardware/bluetooth
    ../../_mixins/hardware/boot/efi.nix
    ../../_mixins/hardware/cpu/intel-cpu.nix
    ../../_mixins/hardware/boot/multiboot.nix
    ../../_mixins/virtualization
    ../../_mixins/virtualization/quickemu.nix
    ../../_mixins/services/security/sudo.nix
    # ../../_mixins/virtualization/k8s.nix
    ../../_mixins/virtualization/virt-manager.nix
    # ../../_mixins/apps/text-editor/vscode.nix
    ../../_mixins/apps/browser/firefox.nix
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
        theme = pkgs.cyberre;
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
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ ];
    };
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
    ];
    plymouth = {
      enable = true;
      themePackages = [ pkgs.adi1090x-plymouth-themes ];
      theme = "deus_ex";
    };

    # Temporary workaround until mwprocapture 4328 patch is merged
    # - https://github.com/NixOS/nixpkgs/pull/221209
    kernelPackages = pkgs.linuxPackages_zen;
    # kernelPackages = pkgs.linuxPackages_xanmod_stable;

    kernelParams = [
      "mitigations=off"
      "zswap.enabled=1"
      "zswap.compressor=lz4hc"
      "zswap.max_pool_percent=10"
      "zswap.zpool=z3fold"
      "mem_sleep_default=deep"
    ];
    kernel.sysctl = {
      "net.ipv4.ip_unprivileged_port_start" = 80; # Podman access port 80
    };
  };

  ##################
  ### FILESYSTEM ###
  ##################

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/NIXOS";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs";
      options = [ "subvol=@root" "rw" "noatime" "nodiratime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "discard=async" ];
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-label/NIXOS";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs";
      options = [ "subvol=@home" "rw" "noatime" "nodiratime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "discard=async" ];
    };

  fileSystems."/.snapshots" =
    {
      device = "/dev/disk/by-label/NIXOS";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs";
      options = [ "subvol=@snapshots" "rw" "noatime" "nodiratime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "discard=async" ];
    };

  fileSystems."/var/tmp" =
    {
      device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@tmp" "rw" "noatime" "nodiratime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "discard=async" ];
    };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-label/NIXOS";
      # device = "/dev/disk/by-uuid/e9cd822d-be82-4f8d-9f05-b594889110a9";
      fsType = "btrfs";
      options = [ "subvol=@nix" "rw" "noatime" "nodiratime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "discard=async" ];
    };

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-label/GRUB";
      # device = "/dev/disk/by-uuid/076D-BEC9";
      fsType = "vfat";
      options = [ "defaults" "noatime" "nodiratime" ];
      noCheck = true;
    };

  zramSwap = {
    enable = true;
    swapDevices = 4;
    memoryPercent = 15;
  };

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
      # sublime4
      # clonegit
      unstable.stacer
      # tidal
    ];
    sessionVariables = {
      # LIBVA_DRIVER_NAME = "nvidia";
      #  # maybe causes firefox crashed?
      #  GBM_BACKEND = "nvidia-drm";
      #  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      #  WLR_NO_HARDWARE_CURSORS = "1";
    };
  };

  services = {
    acpid = {
      enable = true;
    };
    # power-profiles-daemon.enable = false;
    # upower.enable = true;
    udev.extraRules = lib.mkMerge [
      ''ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"'' # autosuspend USB devices
      ''ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"'' # autosuspend PCI devices
      ''ACTION=="add", SUBSYSTEM=="net", NAME=="enp*", RUN+="${pkgs.ethtool}/sbin/ethtool -s $name wol d"'' # disable Ethernet Wake-on-LAN
    ];
    btrfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
    };
    xserver = {
      # videoDrivers = [ "i915" ];
      # displayManager.sessionCommands = ''
      #   ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 1 0
      #   ${pkgs.xorg.xrandr}/bin/xrandr --auto
      # '';
      #######################
      ### Xserver configs ###
      #######################
      layout = lib.mkForce "br";
      # xkbVariant = "pc105";
      xkbModel = lib.mkForce "pc105";
      xkbOptions = "grp:alt_shift_toggle";
      libinput = {
        enable = true;
        touchpad = {
          # horizontalScrolling = true;
          # tappingDragLock = false;
          tapping = false;
          naturalScrolling = true;
          scrollMethod = "twofinger";
          disableWhileTyping = true;
          clickMethod = "clickfinger";
        };
      };
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
      exportConfiguration = true;
    };
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
  };

  ### Load z3fold and lz4

  systemd = {
    services = {
      zswap = {
        description = "Enable ZSwap, set to LZ4 and Z3FOLD";
        enable = true;
        wantedBy = [ "basic.target" ];
        path = [ pkgs.bash ];
        serviceConfig = {
          ExecStart = ''${pkgs.bash}/bin/bash -c 'cd /sys/module/zswap/parameters&& \
      echo 1 > enabled&& \
      echo 20 > max_pool_percent&& \
      echo lz4hc > compressor&& \
      echo z3fold > zpool'
      '';
          Type = "simple";
        };
      };

      ### Limit resources used by nix-daemon
      nix-daemon.serviceConfig = {
        MemoryMax = "4G";
        MemorySwapMax = "4G";
      };
    };

    sleep.extraConfig = ''
      AllowHibernation=no
      AllowSuspend=yes
      AllowSuspendThenHibernate=no
      AllowHybridSleep=no
    '';
  };
}
