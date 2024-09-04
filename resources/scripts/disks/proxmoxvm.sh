#!/usr/bin/env bash

# Variables
DRIVE="/dev/sda"
BTRFS_OPTS="noatime,ssd,compress-force=zstd:15,space_cache=v2,nodatacow,commit=120,discard=async"


setenforce 0 # disable SELInux for now

### Partition
sgdisk --zap-all ${DRIVE}
parted --sscript --fix --align optimal ${DRIVE} mklabel gpt
sgdisk -n 0:0:+600M ${DRIVE}
sgdisk -t 1:ef00 ${DRIVE}
sgdisk -c 1:'EFI system partition' ${DRIVE}
sgdisk -n 0:0:+1G ${DRIVE}
sgdisk -t 2:8300 ${DRIVE}
sgdisk -c 2:'BOOT partition' ${DRIVE}
sgdisk -n 0:0:0 ${DRIVE}
sgdisk -t 3:8300 ${DRIVE}
sgdisk -c 3:'NixOS root partition' ${DRIVE}

# Just like NixOS partition way
mkfs.fat -F 32 -n SYS ${DRIVE}1
mkfs.ext4 -F -L BOOT ${DRIVE}2
mkfs.btrfs -f -L NixOS ${DRIVE}3

mount ${DRIVE}3 /mnt
cd /mnt

# Subvolumes
btrfs subvolume create @
btrfs subvolume create @cache
btrfs subvolume create @home
btrfs subvolume create @images
btrfs subvolume create @log
btrfs subvolume create @snapshots

cd
umount -Rv /mnt

### Mount subvolumes
mount -o $BTRFS_OPTS,subvol=@ /dev/disk/by-label/NixOS /mnt
mkdir -pv /mnt/{boot,home,.snapshots,var/{log,cache,lib/libvirt/images}}

mount -o $BTRFS_OPTS,subvol=@home /dev/disk/by-label/NixOS /mnt/home
mount -o $BTRFS_OPTS,subvol=@images /dev/disk/by-label/NixOS /mnt/var/lib/libvirt/images
mount -o $BTRFS_OPTS,subvol=@log /dev/disk/by-label/NixOS /mnt/var/log
mount -o $BTRFS_OPTS,subvol=@cache /dev/disk/by-label/NixOS /mnt/var/cache
mount -o $BTRFS_OPTS,subvol=@snapshots /dev/disk/by-label/NixOS /mnt/.snapshots
mount /dev/disk/by-label/BOOT /mnt/boot
mkdir -pv /mnt/boot/efi
mount -t vfat -o defaults,noatime,nodiratime /dev/disk/by-label/SYS /mnt/boot/efi

### Mount sudo fs
udevadm trigger
mkdir -pv /mnt/{proc,sys,dev/pts}
mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
mount -B /dev /mnt/dev
mount -t devpts /mnt/dev/pts
