{ lib, modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (import ./disks.nix { })
    ../../_mixins/hardware/boot/systemd-boot.nix
    ../../_mixins/hardware/sound/pipewire.nix
  ];

  swapDevices = [{
    device = "/swap";
    size = 1024;
  }];

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

  boot = {
    initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
