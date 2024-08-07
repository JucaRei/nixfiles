# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      # (modulesPath + "/profiles/qemu-guest.nix")
      (modulesPath + "/virtualisation/qemu-vm.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [
        "ahci"
        "xhci_pci"
        "virtio_pci"
        "sr_mod"
        "virtio_blk"

        # mildly improves performance for the disk encryption
        "aesni_intel"
        "cryptd"
        "usb_storage"
      ];
      kernelModules = [ ];
      systemd = {
        enable = true; # this enabled systemd support in stage1 - required for the below setup
        services.rollback = {
          description = "Rollback BTRFS root subvolume to a pristine state";
          wantedBy = [
            "initrd.target"
          ];

          after = [
            # LUKS/TPM process
            "systemd-cryptsetup@enc.service"
          ];

          before = [
            "sysroot.mount"
          ];

          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            mkdir -p /mnt

            # We first mount the btrfs root to /mnt
            # so we can manipulate btrfs subvolumes.
            mount -o subvol=/ /dev/mapper/enc /mnt

            # While we're tempted to just delete /root and create
            # a new snapshot from /root-blank, /root is already
            # populated at this point with a number of subvolumes,
            # which makes `btrfs subvolume delete` fail.
            # So, we remove them first.
            #
            # /root contains subvolumes:
            # - /root/var/lib/portables
            # - /root/var/lib/machines

            btrfs subvolume list -o /mnt/@root |
              cut -f9 -d' ' |
              while read subvolume; do
                echo "deleting /$subvolume subvolume..."
                btrfs subvolume delete "/mnt/$subvolume"
              done &&
              echo "deleting /@root subvolume..." &&
              btrfs subvolume delete /mnt/@root
            echo "restoring blank /root subvolume..."
            btrfs subvolume snapshot /mnt/root-blank /mnt/@root

            # Once we're done rolling back to a blank snapshot,
            # we can unmount /mnt and continue on the boot process.
            umount /mnt
          '';
        };
      };
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    kernelParams = [
      # The passive default severely degrades performance.
      "intel_pstate=active"
    ];

    initrd.luks.devices."enc".device = "/dev/disk/by-uuid/1359c3b3-9cd8-4394-bb9c-b54b0448d2d5";
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@root" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "nodatacow" "commit=120" "discard=async" ];
    };

    "/home" = {
      device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@home" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "nodatacow" "commit=120" "discard=async" ];
    };

    "/nix" = {
      device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@nix" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "nodatacow" "commit=120" "discard=async" ];
    };

    "/persist" = {
      device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@persist" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "nodatacow" "commit=120" "discard=async" ];
      neededForBoot = true; # <- add this
    };

    "/var/log" = {
      device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@log" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "nodatacow" "commit=120" "discard=async" ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [
        "defaults"
        "noatime"
        "nodiratime"
        "x-gvfs-hide" # hide from filemanager
      ];
    };
  };

  swapDevices =
    [{ device = "/dev/disk/by-label/SWAP"; }];

  environment.persistence = {
    "/persist" = {
      directories = [
        "/etc/nixos"
        "/etc/NetworkManager/system-connections"
        "/etc/secureboot"
        "/var/db/sudo"
      ];

      files = [
        "/etc/machine-id"

        # ssh stuff
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        # if you use docker or LXD, also persist their directories
      ];
    };
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault
    true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault
    "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
