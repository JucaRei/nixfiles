#!/bin/sh

DRIVE="/dev/sda"

sgdisk -Z ${DRIVE}
sgdisk -n 0:0:650MiB ${DRIVE}
sgdisk -n 0:0:-5GiB ${DRIVE}
sgdisk -n 0:0:0 ${DRIVE}

sgdisk -t 1:EF00 ${DRIVE}
sgdisk -c 1:"EFI FileSystem partition" ${DRIVE}
sgdisk -t 2:8300 ${DRIVE}
sgdisk -c 2:"Nixos FileSystem" ${DRIVE}
sgdisk -t 3:8200 ${DRIVE}
sgdisk -c 3:"Nix Swap" ${DRIVE}
parted ${DRIVE}1 -- set 1 esp on
sgdisk -p ${DRIVE}

# EFI system partition

BOOT_PARTITION="/dev/sda1"
ROOT_PARTITION="/dev/sda2"
SWAP_PARTITION="/dev/sda3"

mkfs.vfat -F32 $BOOT_PARTITION -n "EFI"
mkfs.btrfs $ROOT_PARTITION -f -L "NIXOS"
mkswap $SWAP_PARTITION -L "SWAP"
swapon /dev/disk/by-label/SWAP

BTRFS_OPTS="rw,noatime,ssd,compress-force=zstd:15,space_cache=v2,nodatacow,commit=120,discard=async"
BTRFS_OPTS2="rw,noatime,ssd,compress-force=zstd:3,space_cache=v2,nodatacow,commit=120,discard=async"
BTRFS_OPTS3="rw,noatime,ssd,compress-force=zstd:6,space_cache=v2,nodatacow,commit=120,discard=async"
# BTRFS_OPTS="rw,noatime,ssd,compress-force=zstd:15,space_cache=v2,commit=120,discard=async"
mount -o $BTRFS_OPTS /dev/disk/by-label/NIXOS /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@nix
btrfs su cr /mnt/@logs
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@snapshots
# btrfs su cr /mnt/@swap
umount -Rv /mnt

# mount -o $BTRFS_OPTS,subvol=@root /dev/vda2 /mnt
mount -o $BTRFS_OPTS3,subvol=@ /dev/disk/by-label/NIXOS /mnt
# mount -o $BTRFS_OPTS,subvol="@root" /dev/disk/by-partlabel/NIXOS /mnt
mkdir -pv /mnt/boot/efi
mkdir -pv /mnt/home
mkdir -pv /mnt/.snapshots
mkdir -pv /mnt/nix
mkdir -pv /mnt/var/log
mkdir -pv /mnt/var/tmp
mount -o $BTRFS_OPTS,subvol=@home /dev/disk/by-label/NIXOS /mnt/home
# mount -o $BTRFS_OPTS,subvol="@home" /dev/disk/by-partlabel/NIXOS /mnt/home
mount -o $BTRFS_OPTS,subvol=@snapshots /dev/disk/by-label/NIXOS /mnt/.snapshots
# mount -o $BTRFS_OPTS,subvol="@snapshots" /dev/disk/by-partlabel/NIXOS /mnt/.snapshots
mount -o $BTRFS_OPTS2,subvol=@tmp /dev/disk/by-label/NIXOS /mnt/var/tmp
# mount -o $BTRFS_OPTS,subvol="@tmp" /dev/disk/by-partlabel/NIXOS /mnt/var/tmp
mount -o $BTRFS_OPTS,subvol=@nix /dev/disk/by-label/NIXOS /mnt/nix
mount -o $BTRFS_OPTS,subvol=@logs /dev/disk/by-label/NIXOS /mnt/var/log
# mount -o $BTRFS_OPTS,subvol="@nix" /dev/disk/by-partlabel/NIXOS /mnt/nix
mount -t vfat -o defaults,noatime,nodiratime /dev/disk/by-label/EFI /mnt/boot/efi
