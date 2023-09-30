#!/bin/sh

# Micro SD 32gb
export DISK=/dev/disk/by-id/mmc-SC32G_0x78fe3e2e
parted /dev/mmcblk0 --mklabel msdos
parted /dev/mmcblk0 --mkpart primary fat32 0MiB 512MiB  #/dev/mmcblk0p1 is /boot
parted /dev/mmcblk0 --mkpart primary fat32 512MiB -2GiB  # This is the ZFS partition
parted /dev/mmcblk0 --mkpart primary linux-swap -2GiB 100% # Swap. This is optional

mkfs.vfat -F32 $DISK-part1 # Format /boot

# Create the zpool
zpool create -f -O mountpoint=none rpool $DISK-part2

# Create some datasets inside the pool
zfs create -o mountpoint=legacy rpool/root
zfs create -o mountpoint=legacy rpool/root/nixos
zfs create -o mountpoint=legacy rpool/home

mount -t zfs rpool/root/nixos /mnt
mkdir /mnt/home
mount -t zfs rpool/home /mnt/home

mkdir /mnt/boot
mount $DISK-part1 /mnt/boot

nixos-generate-config --root /mnt
