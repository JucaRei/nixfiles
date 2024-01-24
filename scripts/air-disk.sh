#!/bin/bash

DRIVE="/dev/sda"

# sgdisk -Z ${DRIVE}
sgdisk -p ${DRIVE}

sgdisk -n 0:0:650MiB ${DRIVE}
sgdisk -n 0:0:-5GiB ${DRIVE}
sgdisk -n 0:0:0 ${DRIVE}

sgdisk -c 1:"EFI FileSystem" ${DRIVE}
sgdisk -c 2:"Nixos Root filesystem" ${DRIVE}
sgdisk -c 3:"Nixos Swap filesystem" ${DRIVE}

sgdisk -t 1:ef00 ${DRIVE}
sgdisk -t 2:8300 ${DRIVE}
sgdisk -t 2:8200 ${DRIVE}

mkfs.vfat -F32 ${DRIVE}1 -n "EFI"
mkfs.btrfs ${DRIVE}2 -f -L "Nixsystem"
mkswap ${DRIVE}3 -L "NixSWAP"
sleep 1
swapon /dev/disk/by-label/NixSWAP

BTRFS_OPTS="noatime,ssd,compress-force=zstd:3,space_cache=v2,commit=120,discard=async"
BTRFS_OPTS2="noatime,ssd,compress-force=zstd:15,space_cache=v2,commit=120,discard=async"

mount -o $BTRFS_OPTS2 ${DRIVE}2 /mnt

btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@snapshots
btrfs su cr /mnt/@logs
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@nix

umount -Rv /mnt

mount -o $BTRFS_OPTS /dev/disk/by-label/Nixsystem /mnt
mkdir -pv /mnt/{boot/efi,home,.snapshots,var/log,var/tmp,nix}

mount -o $BTRFS_OPTS,subvol=@home /dev/disk/by-label/Nixsystem /mnt/home
mount -o $BTRFS_OPTS2,subvol=@snapshots /dev/disk/by-label/Nixsystem /mnt/.snapshots
mount -o $BTRFS_OPTS,subvol=@logs /dev/disk/by-label/Nixsystem /mnt/var/log
mount -o $BTRFS_OPTS,subvol=@tmp /dev/disk/by-label/Nixsystem /mnt/var/tmp
mount -o $BTRFS_OPTS2,subvol=@nix /dev/disk/by-label/Nixsystem /mnt/nix
mount -t vfat -o defaults,noatime,nodiratime /dev/disk/by-label/EFI /mnt/boot/efi

# nixos-generate-config --root /mnt
