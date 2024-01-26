{ inputs, lib, pkgs, config, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.apple-macbook-air-4
    # inputs.nixos-hardware.nixosModules.common-cpu-intel-sandy-bridge
    # inputs.nixos-hardware.nixosModules.common-pc-ssd
    # (import ./disks-1.nix { })
    (import ./disks-btrfs.nix { })
    # (import ./btrfs.nix { })
    # (import ./disks-ext4.nix { })
    ../../_mixins/hardware/boot/efi.nix
    # ../../_mixins/hardware/boot/systemd-boot.nix
    # ../../_mixins/hardware/boot/refind.nix
    # ../../_mixins/hardware/boot/no-hz.nix
    ../../_mixins/hardware/bluetooth
    # ../../_mixins/apps/browser/firefox.nix
    # ../../_mixins/apps/text-editor/vscode.nix
    ../../_mixins/hardware/graphics/intel/intel-old.nix
    # ../../_mixins/hardware/sound/pipewire.nix
    ../../_mixins/hardware/sound/pulseaudio.nix
    ../../_mixins/services/security/doas.nix
    # ../../_mixins/sys/ananicy.nix
    # ../../_mixins/virtualization
  ];

  boot = {
    loader = {
      grub = {
        copyKernels = true;
        # forcei686 = true;
      };
      systemd-boot.enable = lib.mkForce false;
      # grub.device = "nodev"; # or "nodev" for efi only
    };

    # blacklistedKernelModules = lib.mkDefault [ "nvidia" "nouveau" ];
    initrd = {
      availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
      verbose = false;
      compressor = "zstd";
      supportedFilesystems = [ "btrfs" "vfat" ];
      systemd = {
        enable = lib.mkForce true;
      };
    };
    # extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
    kernelModules = [
      "acpi_backlight=vendor"
      "applesmc"
      "i915"
      # "i965"
      "wl"
      "crc32c-intel"
      "z3fold"
      "lz4hc"
      "lz4hc_compress"
      "boot.shell_on_fail"
      "boot.panic_on_fail"
    ];
    kernelParams = [
      # "hid_apple.iso_layout=0"
      # "hid_apple.fnmode=1"
      # "hid_apple.swap_fn_leftctrl=0"
      # "hid_apple.swap_opt_cmd=0" # This will switch the left Alt and Cmd key as well as the right Alt/AltGr and Cmd key.
      # "intel_pstate=ondemand"
      # "i915.enable_rc6=7"
      # "acpi_backlight=vendor"
      "i915.enable_psr=0"
      "i915.modeset=1"
      "acpi_mask_gpe=0x15"
      # "i915.force_probe=0116" # Force enable my intel graphics
      #"video=efifb:off" # Disable efifb driver, which crashes Xavier AGX/NX
      #"video=efifb"
      "zswap.enabled=1"
      "zswap.compressor=lz4hc"
      "zswap.max_pool_percent=20"
      "zswap.zpool=z3fold"
      "fs.inotify.max_user_watches=524288"
      "mitigations=off"

      "nowatchdog"
      "msr.allow_writes=on"
      "pcie_aspm=force"
      "module.sig_unenforce"
      "intel_idle.max_cstate=1"
      "cryptomgr.notests"
      "initcall_debug"
      "no_timer_check"
      "noreplace-smp"
      "page_alloc.shuffle=1"
      "rcupdate.rcu_expedited=1"
      "tsc=reliable"

      # # Intel vm passthrought
      # "intel_iommu=on"
      # "i915.enable_guc=7"
    ];
    kernel.sysctl = lib.mkForce {
      "vm.vfs_cache_pressure" = 40;
      "vm.swappiness" = 10;
      "vm.dirty_bytes" = 335544320; #320M
      "vm.dirty_background_bytes" = 167772160; #160M
      # "vm.dirty_background_ratio" = 1;
      # "vm.dirty_ratio" = 50;
      "dev.i915.perf_stream_paranoid" = 0;
    };
    kernelPackages = pkgs.linuxPackages_lqx;
    # kernelPackages = pkgs.linuxPackages_xanmod_stable;

    # kernelPackages = pkgs.linuxPackages_5_10;
    # kernelPackages = pkgs.linuxPackages_5_10_hardened;
    supportedFilesystems = [
      # "cifs"
      # "nfs"
      "btrfs"
    ];

    plymouth = {
      theme = "breeze";
      enable = lib.mkForce false;
    };
    # loader.grub.efiInstallAsRemovable = lib.mkForce true;
  };

  ###################
  ### Hard drives ###
  ###################

  fileSystems = lib.mkForce {
    "/" = {
      device = "/dev/disk/by-label/NIXOS";
      # device = "/dev/disk/by-uuid/5a903c61-7dd4-47e8-9ab8-0ee4732d4f26";
      fsType = "btrfs";
      options = [
        "subvol=@"
        # "rw"
        "noatime"
        "nodiratime"
        "ssd"
        "nodatacow"
        "compress-force=zstd:6"
        "space_cache=v2"
        "commit=120"
        # "autodefrag"
        "discard=async"
      ];
    };
    "/home" = {
      device = "/dev/disk/by-label/NIXOS";
      # device = "/dev/disk/by-uuid/5a903c61-7dd4-47e8-9ab8-0ee4732d4f26";
      fsType = "btrfs";
      options = [
        "subvol=@home"
        "rw"
        "noatime"
        "nodiratime"
        "ssd"
        # "nodatacow"
        "compress-force=zstd:15"
        "space_cache=v2"
        "commit=120"
        # "autodefrag"
        "discard=async"
      ];
    };
    "/nix" = {
      device = "/dev/disk/by-label/NIXOS";
      # device = "/dev/disk/by-uuid/5a903c61-7dd4-47e8-9ab8-0ee4732d4f26";
      fsType = "btrfs";
      options = [
        "subvol=@nix"
        # "rw"
        "noatime"
        "nodiratime"
        "ssd"
        "nodatacow"
        "compress-force=zstd:15"
        "space_cache=v2"
        "commit=120"
        # "autodefrag"
        "discard=async"
      ];
    };
    "/var/log" = {
      # device = "/dev/disk/by-uuid/5a903c61-7dd4-47e8-9ab8-0ee4732d4f26";
      device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [
        "subvol=@logs"
        # "rw"
        "noatime"
        "nodiratime"
        "ssd"
        "nodatacow"
        "compress-force=zstd:15"
        "space_cache=v2"
        "commit=120"
        # "autodefrag"
        "discard=async"
      ];
    };
    "/var/tmp" = {
      device = "/dev/disk/by-label/NIXOS";
      # device = "/dev/disk/by-uuid/5a903c61-7dd4-47e8-9ab8-0ee4732d4f26";
      fsType = "btrfs";
      options = [
        "subvol=@tmp"
        # "rw"
        "noatime"
        "nodiratime"
        "ssd"
        "nodatacow"
        "compress-force=zstd:3"
        "space_cache=v2"
        "commit=120"
        # "autodefrag"
        "discard=async"
      ];
    };
    "/.snapshots" = {
      device = "/dev/disk/by-label/NIXOS";
      # device = "/dev/disk/by-uuid/5a903c61-7dd4-47e8-9ab8-0ee4732d4f26";
      fsType = "btrfs";
      options = [
        "subvol=@snapshots"
        # "rw"
        "noatime"
        "nodiratime"
        "ssd"
        "nodatacow"
        "compress-force=zstd:15"
        "space_cache=v2"
        "commit=120"
        # "autodefrag"
        "discard=async"
      ];
    };
    "/boot/efi" = {
      device = "/dev/disk/by-label/EFI";
      # device = "/dev/disk/by-uuid/B005-A805";
      fsType = "vfat";
      options = [ "defaults" "noatime" "nodiratime" ];
      noCheck = true;
    };
  };

  swapDevices = [{
    device = "/dev/disk/by-label/SWAP";
    # device = "/dev/disk/by-uuid/b6036d8c-4016-4125-9e82-c237694d8173";
    # options = [ "defaults" "noatime" ];
    ### SWAPFILE
    #device = "/swap/swapfile";
    #size = 2 GiB;
    #device = "/swap/swapfile";
    #size = (1024 * 2); # RAM size
    #size = (1024 * 16) + (1024 * 2); # RAM size + 2 GB
  }];


  # swapDevices = [{
  #   device = "/swap";
  #   size = 5120;
  # }];


  environment.systemPackages = with pkgs; [
    # unstable.tidal-dl
    # unstable.nvchad
    inxi

    # xorg.xbacklight
    # xorg.xrdb
    cifs-utils
    # kodi

    refind
    efibootmgr
  ];

  hardware = {
    brillo.enable = true;
  };

  services = {
    hardware = {
      bolt.enable = true;
    };
    mbpfan = {
      enable = true;
      aggressive = true;
    };
    xserver = {
      xkb = {
        # Configure the keyboard to use US international with dead keys. This allows
        # to use tildes in Spanish while using the US layout. Also, always remap Caps
        # Lock to Ctrl.
        layout = "us";
        variant = "intl";
        options = "eurosign:e,ctrl:nocaps";
        model = "pc105";
      };
      # deviceSection = lib.mkDefault ''
      #   Option "TearFree" "true"
      # '';
    };

    fstrim = {
      enable = lib.mkDefault true;
    };

    xserver = {
      libinput = {
        enable = true;
        touchpad = {
          tapping = lib.mkDefault true;
          scrollMethod = "twofinger";
          naturalScrolling = false;
          accelProfile = "adaptive";
          disableWhileTyping = true;
          sendEventsMode = "disabled-on-external-mouse";
        };
        mouse = {
          scrollMethod = "button";
        };
      };
    };
  };

  # powerManagement.cpuFreqGovernor = "ondemand";

  # Adjust MTU for Virgin Fibre
  # - https://search.nixos.org/options?channel=23.05&show=networking.networkmanager.connectionConfig&from=0&size=50&sort=relevance&type=packages&query=networkmanager
  networking.networkmanager.connectionConfig = {
    # "ethernet.mtu" = 1462;
    # "wifi.mtu" = 1462;
  };

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
          echo 25 > max_pool_percent&& \
          echo lz4hc > compressor&& \
          echo z3fold > zpool'
          '';
          Type = "simple";
        };
      };
      # Limit resources used by nix-daemon.
      nix-daemon.serviceConfig = {
        MemoryMax = "1G";
        MemorySwapMax = "1G";
        AllowedCPUs = "1-2";
      };
    };
  };

  programs = {
    kbdlight = {
      enable = true;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system = {
    # change nixos stateVersion
    stateVersion = lib.mkForce "22.11";
  };
}
