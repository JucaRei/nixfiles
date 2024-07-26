#!/bin/sh


BTRFS_OPTS="rw,noatime,ssd,compress-force=zstd:15,space_cache=v2,nodatacow,commit=120,discard=async"
BTRFS_OPTS2="rw,noatime,ssd,compress-force=zstd:3,space_cache=v2,nodatacow,commit=120,discard=async"
BTRFS_OPTS3="rw,noatime,ssd,compress-force=zstd:6,space_cache=v2,nodatacow,commit=120,discard=async"
# BTRFS_OPTS="rw,noatime,ssd,compress-force=zstd:15,space_cache=v2,commit=120,discard=async"


mount -o $BTRFS_OPTS3,subvol=@ /dev/disk/by-label/NIXOS /mnt
mount -o $BTRFS_OPTS,subvol=@home /dev/disk/by-label/NIXOS /mnt/home
mount -o $BTRFS_OPTS,subvol=@snapshots /dev/disk/by-label/NIXOS /mnt/.snapshots
mount -o $BTRFS_OPTS2,subvol=@tmp /dev/disk/by-label/NIXOS /mnt/var/tmp
mount -o $BTRFS_OPTS,subvol=@nix /dev/disk/by-label/NIXOS /mnt/nix
mount -o $BTRFS_OPTS,subvol=@logs /dev/disk/by-label/NIXOS /mnt/var/log
mount -t vfat -o defaults,noatime,nodiratime /dev/disk/by-label/EFI /mnt/boot/efi

nixos-enter
