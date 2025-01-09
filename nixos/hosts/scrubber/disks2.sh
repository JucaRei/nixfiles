#!/bin/sh

DRIVE="/dev/sda"

sgdisk -Z ${DRIVE}
sgdisk -n 0:0:512MB ${DRIVE}
sgdisk -n 0:0:-3.5GB ${DRIVE}
sgdisk -n 0:0:0 ${DRIVE}

sgdisk -t 1:EF00 ${DRIVE}
sgdisk -c 1:"EFI FileSystem partition" ${DRIVE}
sgdisk -t 2:8300 ${DRIVE}
sgdisk -c 2:"Nixos FileSystem" ${DRIVE}
sgdisk -t 3:8200 ${DRIVE}
sgdisk -c 3:"Nix Swap" ${DRIVE}
parted ${DRIVE}1 -- set 1 esp on
sgdisk -p ${DRIVE}

export BOOT_PARTITION="${DRIVE}1"
export ROOT_PARTITION="${DRIVE}2"
export SWAP_PARTITION="${DRIVE}3"

mkfs.vfat -F32 $BOOT_PARTITION -n "EFIBOOT"
mkfs.btrfs $ROOT_PARTITION -f -L "nixsystem"
mkswap $SWAP_PARTITION -L "swap"

sleep 1
swapon /dev/disk/by-label/swap
sleep 1

BTRFS_OPTS="rw,noatime,ssd,compress-force=zstd:15,space_cache=v2,nodatacow,commit=120,discard=async"
mount -o $BTRFS_OPTS /dev/disk/by-label/nixsystem /mnt
btrfs su cr /mnt/@rootfs
btrfs su cr /mnt/@home
btrfs su cr /mnt/@nix
btrfs su cr /mnt/@logs
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@snapshots
umount -Rv /mnt

mount -o $BTRFS_OPTS,subvol=@rootfs /dev/disk/by-label/nixsystem /mnt
mkdir -pv /mnt/{boot,home,.snapshots,nix,var/tmp,var/log}
mount -o $BTRFS_OPTS2,subvol=@home /dev/disk/by-label/nixsystem /mnt/home
mount -o $BTRFS_OPTS,subvol=@snapshots /dev/disk/by-label/nixsystem /mnt/.snapshots
mount -o $BTRFS_OPTS2,subvol=@tmp /dev/disk/by-label/nixsystem /mnt/var/tmp
mount -o $BTRFS_OPTS,subvol=@nix /dev/disk/by-label/nixsystem /mnt/nix
mount -o $BTRFS_OPTS,subvol=@logs /dev/disk/by-label/nixsystem /mnt/var/log
# mount /dev/disk/by-label/BOOT /mnt/boot
mount -t vfat -o defaults,noatime,nodiratime /dev/disk/by-label/EFIBOOT /mnt/boot
