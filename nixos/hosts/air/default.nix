{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel-sandy-bridge
    inputs.nixos-hardware.nixosModules.apple-macbook-air-4
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    # (import ./disks.nix { })
    ../../_mixins/hardware/boot/efi.nix
    ../../_mixins/hardware/boot/no-hz.nix
    ../../_mixins/hardware/bluetooth
    ../../_mixins/hardware/graphics/intel-old.nix
    ../../_mixins/hardware/sound/pipewire.nix
    ../../_mixins/virtualization
  ];

  boot = {
    blacklistedKernelModules = lib.mkDefault [ "nvidia" "nouveau" ];
    initrd = {
      availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      verbose = false;
      compressor = "zstd";
      supportedFilesystems = [ "btrfs" ];
    };
    kernelModules = [
      "kvm-intel"
      "applesmc"
      # "i915"
      "i965"
      "wl"
      "crc32c-intel"
      "z3fold"
      "lz4hc"
      "lz4hc_compress"
    ];
    kernelParams = [
      "hid_apple.iso_layout=0"
      "hid_apple.swap_opt_cmd=1" # This will switch the left Alt and Cmd key as well as the right Alt/AltGr and Cmd key.
      "acpi_backlight=vendor"
      "acpi_mask_gpe=0x15"
      "i915.force_probe=0116" # Force enable my intel graphics
      #"video=efifb:off" # Disable efifb driver, which crashes Xavier AGX/NX
      #"video=efifb"
      "zswap.enabled=1"
      "zswap.compressor=lz4hc"
      "zswap.max_pool_percent=20"
      "zswap.zpool=z3fold"
      "fs.inotify.max_user_watches=524288"
      "mitigations=off"

      # # Intel vm passthrought
      # "intel_iommu=on"
      # "i915.enable_guc=7"
      # "i915.force_probe=46a6"
    ];
    kernel.sysctl = {
      "vm.vfs_cache_pressure" = 400;
      "vm.swappiness" = 20;
      "vm.dirty_background_ratio" = 1;
      "vm.dirty_ratio" = 50;
      "dev.i915.perf_stream_paranoid" = 0;
    };
    kernelPackages = pkgs.linuxPackages_lqx;
    supportedFilesystems = [ "btrfs" ];

    plymouth = {
      theme = "breeze";
      enable = true;
    };
  };

  ###################
  ### Hard drives ###
  ###################

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "rw"
      "noatime"
      "nodiratime"
      "ssd"
      "nodatacow"
      "compress-force=zstd:15"
      "space_cache=v2"
      "commit=120"
      "autodefrag"
      "discard=async"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "rw"
      "noatime"
      "nodiratime"
      "ssd"
      "nodatacow"
      "compress-force=zstd:15"
      "space_cache=v2"
      "commit=120"
      "autodefrag"
      "discard=async"
    ];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-label/NIXOS";
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
      "autodefrag"
      "discard=async"
    ];
  };

  fileSystems."/var/tmp" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@tmp"
      "rw"
      "noatime"
      "nodiratime"
      "ssd"
      "nodatacow"
      "compress-force=zstd:15"
      "space_cache=v2"
      "commit=120"
      "autodefrag"
      "discard=async"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
      "rw"
      "noatime"
      "nodiratime"
      "ssd"
      "nodatacow"
      "compress-force=zstd:15"
      "space_cache=v2"
      "commit=120"
      "autodefrag"
      "discard=async"
    ];
  };

  #fileSystems."/swap" = {
  #  device = "/dev/disk/by-partlabel/NIXOS";
  #  fsType = "btrfs";
  #  options = [
  #    "subvol=@swap"
  #    #"compress=lz4"
  #    "defaults"
  #    "noatime"
  #  ]; # Note these options effect the entire BTRFS filesystem and not just this volume, with the exception of `"subvol=swap"`, the other options are repeated in my other `fileSystem` mounts
  #};

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/8773-B4F8";
    fsType = "vfat";
    options = [ "defaults" "noatime" "nodiratime" ];
    noCheck = true;
  };

  swapDevices = [{
    device = "/dev/disk/by-partlabel/SWAP";
    options = [ "defaults" "noatime" ];
    ### SWAPFILE
    #device = "/swap/swapfile";
    #size = 2 GiB;
    #device = "/swap/swapfile";
    #size = (1024 * 2); # RAM size
    #size = (1024 * 16) + (1024 * 2); # RAM size + 2 GB
  }];

  environment.systemPackages = with pkgs; [
    # unstable.tidal-dl
    # unstable.nvchad
    inxi

    xorg.xbacklight
    xorg.xrdb
    cifs-utils
  ];

  hardware = { };

  services = {
    hardware = {
      bolt.enable = true;
    };
    mbpfan = {
      enable = true;
      aggressive = true;
    };
    xserver.deviceSection = lib.mkDefault ''
      Option "TearFree" "true"
    '';
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  # Adjust MTU for Virgin Fibre
  # - https://search.nixos.org/options?channel=23.05&show=networking.networkmanager.connectionConfig&from=0&size=50&sort=relevance&type=packages&query=networkmanager
  networking.networkmanager.connectionConfig = {
    # "ethernet.mtu" = 1462;
    # "wifi.mtu" = 1462;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
