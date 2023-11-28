#!/bin/bash

DRIVE="/dev/sda" 

sgdisk -Z ${DRIVE}
sgdisk -p ${DRIVE}

sgdisk -n 0:0:512MiB ${DRIVE}
sgdisk -n 0:0:6GiB ${DRIVE}
sgdisk -n 0:0:0 ${DRIVE}

sgdisk -c 1:"EFIBOOT" ${DRIVE}
sgdisk -c 2:"SWAP" ${DRIVE}
sgdisk -c 3:"NIXOS" ${DRIVE}

sgdisk -t 1:ef00 ${DRIVE}
sgdisk -t 2:8200 ${DRIVE}
sgdisk -t 2:8300 ${DRIVE}

mkfs.vfat -F32 ${DRIVE}1 -n "EFI"
mkswap ${DRIVE}2 -L "NixSWAP"
mkfs.btrfs ${DRIVE}3 -f -L "Nixsystem"

BTRFS_OPTS="noatime,ssd,compress-force=zstd:3,space_cache=v2,commit=120,discard=async"
BTRFS_OPTS2="noatime,ssd,compress-force=zstd:15,space_cache=v2,commit=120,discard=async"

mount -o $BTRFS_OPTS2 ${DRIVE}3 /mnt

btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@snapshots
btrfs su cr /mnt/@logs
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@nix

umount -Rv /mnt

mount -o $BTRFS_OPTS ${DRIVE}3 /mnt
mkdir -pv /mnt/{boot/efi,home,.snapshots,var/log,var/tmp,nix}

mount -o $BTRFS_OPTS,subvol=@home /dev/disk/by-label/Nixsystem /mnt/home
mount -o $BTRFS_OPTS2,subvol=@snapshots /dev/disk/by-label/Nixsystem /mnt/.snapshots
mount -o $BTRFS_OPTS,subvol=@logs /dev/disk/by-label/Nixsystem /mnt/var/log
mount -o $BTRFS_OPTS,subvol=@tmp /dev/disk/by-label/Nixsystem /mnt/var/tmp
mount -o $BTRFS_OPTS2,subvol=@nix /dev/disk/by-label/Nixsystem /mnt/nix
mount -t vfat -o defaults,noatime,nodiratime /dev/disk/by-label/EFI /mnt/boot/efi
swapon /dev/disk/by-label/NixSWAP

nixos-generate-config --root /mnt