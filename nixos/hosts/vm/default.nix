{ lib, modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (import ./disks-btrfs.nix { })
    ../../_mixins/hardware/boot/efi.nix
    ../../_mixins/hardware/sound/pipewire.nix
    ../../_mixins/hardware/bluetooth/default.nix
    ../../_mixins/sys/swapfile.nix
    ../../_mixins/services/security/doas.nix
    ../../_mixins/virtualization/podman.nix
  ];

  # swapDevices = [{
  #   device = "/var/lib/swapfile";
  #   size = 2 * 1024;
  # }];

  swapDevices = [{
    device = "/.swap/swapfile";
    size = 2048;
  }];

  # fileSystems."/mnt/nixos-nas/encrypted" = {
  #   device = "10.42.0.1:/export/encrypted";
  #   fsType = "nfs";
  #   #options = [ "nfsvers=4.2" ];
  #   options = [
  #     "proto=tcp"
  #     "mountproto=tcp" # NFSv3 only
  #     "soft" # return errors to client when access is lost, instead of waiting indefinitely
  #     "softreval" # use cache even when access is lost
  #     "timeo=100"
  #     "noatime"
  #     "nodiratime"
  #     "noauto" # don't mount until needed
  #     #"x-systemd.requires=example.service"
  #     "x-systemd.automount" # mount when accessed
  #     "_netdev" # wait for network
  #     "x-systemd.mount-timeout=5"
  #     "x-systemd.idle-timeout=3600"
  #   ];
  # };

  # Use linux-zen
  # https://discourse.nixos.org/t/how-to-get-compatible-hardened-kernel-for-zfs-module/32491/3
  # boot.kernelPackages =
  # with builtins; with lib; let
  #   latestCompatibleVersion = config.boot.zfs.package.latestCompatibleLinuxPackages.kernel.version;
  #   zenPackages = filterAttrs (name: packages: hasSuffix "zen" name && (tryEval packages).success) pkgs.linuxKernel.packages;
  #   compatiblePackages = filter (packages: compareVersions packages.kernel.version latestCompatibleVersion <= 0) (attrValues zenPackages);
  #   orderedCompatiblePackages = sort (x: y: compareVersions x.kernel.version y.kernel.version > 0) compatiblePackages;
  # in head orderedCompatiblePackages;

  # boot.initrd.postDeviceCommands =
  #   lib.mkAfter "	zfs rollback -r rpool/local/root@blank\n";

  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # boot.loader.generationsDir.copyKernels = true;
  # boot.loader.grub = {
  #   enable = true;
  #   efiInstallAsRemovable = true;
  #   copyKernels = true;
  #   efiSupport = true;
  #   zfsSupport = true;
  #   device = "nodev";
  #   default = "1";
  # };

  # # ZFS ARC Size 8GB
  # boot.kernelParams = [ "zfs.zfs_arc_max=8589934592" ];

  # boot.zfs.forceImportAll = true;

  # # ZFS already has its own scheduler. Without this computer freezes for a second under heavy load.
  # services.udev.extraRules = lib.optionalString (config.boot.zfs.enabled) ''
  #   ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  # '';


  services.xserver = {
    layout = lib.mkForce "br";
    exportConfiguration = true;
    virtualScreen = {
      x = 1920;
      y = 1080;
    };
    resolutions = [
      {
        x = 1920;
        y = 1080;
      }
      {
        x = 1600;
        y = 1200;
      }
    ];
    dpi = 96;
    logFile = "/var/log/Xorg.0.log";
  };

  boot = {
    initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
    kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = pkgs.linuxKernel.packages.linux_5_15_hardened.system76;

    loader = {
      grub = {
        gfxmodeEfi = lib.mkForce "1920x1080";
      };
    };
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
