# { config, lib, pkgs, modulesPath, ... }:

# let
#   BTRFS_OPTS = [
#     "noatime"
#     "nodiratime"
#     "nodatacow"
#     "ssd"
#     "compress-force=zstd:15"
#     "space_cache=v2"
#     "commit=120"
#     "discard=async"
#   ];

#   BTRFS_OPTS2 = [
#     "noatime"
#     "nodiratime"
#     "nodatacow"
#     "ssd"
#     "compress-force=zstd:5"
#     "space_cache=v2"
#     "commit=120"
#     "discard=async"
#   ];
# in
# {
#   fileSystems = {
#     "/" = {
#       # device = "/dev/disk/by-label/NixOS";
#       device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
#       fsType = "btrfs";
#       options = [
#         "subvol=@rootsystem"
#         "x-gvfs-hide" # hide from filemanager
#       ] ++ BTRFS_OPTS2;
#     };

#     "/home" = {
#       # device = "/dev/disk/by-label/NixOS";
#       device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
#       fsType = "btrfs";
#       options = [
#         "subvol=@home"
#       ] ++ BTRFS_OPTS;
#     };

#     "/var/snapshots" = {
#       # device = "/dev/disk/by-label/NixOS";
#       device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
#       fsType = "btrfs";
#       options = [
#         "subvol=@snapshots"
#       ] ++ BTRFS_OPTS;
#     };

#     "/var/log" = {
#       # device = "/dev/disk/by-label/NixOS";
#       device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
#       fsType = "btrfs";
#       options = [
#         "subvol=@logs"
#       ] ++ BTRFS_OPTS2;
#     };

#     "/var/tmp" = {
#       # device = "/dev/disk/by-label/NixOS";
#       device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
#       fsType = "btrfs";
#       options = [
#         "subvol=@tmp"
#       ] ++ BTRFS_OPTS2;
#     };

#     "/nix" = {
#       # device = "/dev/disk/by-label/NixOS";
#       device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
#       fsType = "btrfs";
#       options = [
#         "subvol=@nix"
#       ] ++ BTRFS_OPTS;
#     };

#     "/boot" = {
#       # device = "/dev/disk/by-label/BOOTLOADER";
#       device = "/dev/disk/by-uuid/DD62-7579";
#       fsType = "vfat";
#       options = [
#         "fmask=0022"
#         "dmask=0022"
#         "defaults"
#         "noatime"
#         "nodiratime"
#         "x-gvfs-hide" # hide from filemanager
#       ];
#       noCheck = true;
#     };
#   };

#   swapDevices = [{
#     device = "/dev/disk/by-uuid/21c74eed-5aad-4452-a5e3-ef17f3639081";
#     # device = "/dev/disk/by-label/SWAP";
#   }];

#   # "/var/swap" = {
#   #   # device = "/dev/disk/by-label/nixos";
#   #   device = "/dev/disk/by-uuid/62107246-5335-41d1-a94b-076b7baae356";
#   #   fstype = "btrfs";
#   #   options = [ "noatime" "ssd_spread" "subvol=@swap" ];
#   # };
# };

# fileSystems."/" = {
#   device = "/dev/disk/by-label/nixos";
#   # device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
#   fsType = "btrfs";
#   options = [
#     "subvol=@root"
#     "x-gvfs-hide" # hide from filemanager
#   ] ++ BTRFS_OPTS2;
# };

# fileSystems."/home" = {
#   device = "/dev/disk/by-label/nixos";
#   # device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
#   fsType = "btrfs";
#   options = [
#     "subvol=@home"
#   ] ++ BTRFS_OPTS;
# };

# fileSystems."/var/snapshots" = {
#   device = "/dev/disk/by-label/nixos";
#   # device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
#   fsType = "btrfs";
#   options = [
#     "subvol=@snapshots"
#   ] ++ BTRFS_OPTS;
# };

# fileSystems."/var/log" = {
#   device = "/dev/disk/by-label/nixos";
#   # device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
#   fsType = "btrfs";
#   options = [
#     "subvol=@log"
#   ] ++ BTRFS_OPTS2;
# };

# fileSystems."/var/tmp" = {
#   device = "/dev/disk/by-label/nixos";
#   # device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
#   fsType = "btrfs";
#   options = [
#     "subvol=@tmp"
#   ] ++ BTRFS_OPTS2;
# };

# fileSystems."/nix" = {
#   device = "/dev/disk/by-label/nixos";
#   # device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
#   fsType = "btrfs";
#   options = [
#     "subvol=@nix"
#   ] ++ BTRFS_OPTS;
# };

# fileSystems."/boot" = {
#   device = "/dev/disk/by-label/BOOT";
#   # device = "/dev/disk/by-uuid/BBF5-D456";
#   fsType = "vfat";
#   options = [
#     "fmask=0022"
#     "dmask=0022"
#     "defaults"
#     "noatime"
#     "nodiratime"
#     "x-gvfs-hide" # hide from filemanager
#   ];
#   # noCheck = true;
# };

# fileSystems."/var/swap" = {
#   # device = "/dev/disk/by-label/nixos";
#   device = "/dev/disk/by-uuid/62107246-5335-41d1-a94b-076b7baae356";
#   fstype = "btrfs";
#   options = [ "noatime" "ssd_spread" "subvol=@swap" ];
# };

# swapDevices = [
#   {
#     device = "/var/swap/swapfile";
#     size = 16384;
#     # device = "/var/swap/swapfile";
#     # device = "/dev/disk/by-label/swap";
#     # device = "/dev/disk/by-partlabel/disk-nvme0-SWAP";
#     # size = "20G";
#   }
# ];

# swapDevices = [{
#   device = "/swapfile";
#   size = 16 * 1024; # 16GB
# }];
# }

# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
      fsType = "btrfs";
      options = [ "subvol=@rootsystem" ];
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };

  fileSystems."/var/log" =
    {
      device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
      fsType = "btrfs";
      options = [ "subvol=@logs" ];
    };

  fileSystems."/var/tmp" =
    {
      device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
      fsType = "btrfs";
      options = [ "subvol=@tmp" ];
    };

  fileSystems."/var/snapshots" =
    {
      device = "/dev/disk/by-uuid/0e3d14f2-f776-4ea3-9316-d02f89ea2b4e";
      fsType = "btrfs";
      options = [ "subvol=@snapshots" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/DD62-7579";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/21c74eed-5aad-4452-a5e3-ef17f3639081"; }];
}
