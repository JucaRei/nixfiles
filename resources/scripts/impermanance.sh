#!/usr/bin/env bash

# Set the disk name to make it easier
DISK=/dev/vda # replace this with the name of the device you are using

sgdisk -Z "$DISK"

BTRFS_OPTS="noatime,ssd,compress-force=zstd:15,space_cache=v2,nodatacow,commit=120,discard=async"

# set up the boot partition
parted "$DISK" --script --fix --align optimal -- mklabel gpt
parted "$DISK" --script --fix --align optimal -- mkpart ESP fat32 1MiB 1GiB
parted "$DISK" -- set 1 boot on

mkfs.vfat -n BOOT "$DISK"1

sgdisk -c 1:"EFI FileSystem partition" ${DRIVE}

# set up the swap partition
parted "$DISK" --script --align optimal -- mkpart Swap linux-swap 1GiB 4GiB
mkswap -L SWAP "$DISK"2
swapon "$DISK"2

sgdisk -c 2:"Nix Swap" ${DRIVE}

parted "$DISK" --script --fix --align optimal -- mkpart primary 9GiB 100%

sgdisk -c 3:"Nixos FileSystem" ${DRIVE}

cryptsetup --verify-passphrase -v luksFormat "$DISK"3 # /dev/sda3
cryptsetup open "$DISK"3 enc


mkfs.btrfs -L NIXOS /dev/mapper/enc

mount -t btrfs /dev/mapper/enc /mnt

# First we create the subvolumes, those may differ as per your preferences
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@persist # some people may choose to put /persist in /mnt/nix, I am not one of those people.
btrfs subvolume create /mnt/@log

btrfs subvolume snapshot -r /mnt/@root /mnt/root-blank

# /
mount -o subvol=@root,"$BTRFS_OPTS" /dev/mapper/enc /mnt

# /home
mkdir /mnt/home
mount -o subvol=@home,"$BTRFS_OPTS" /dev/mapper/enc /mnt/home

# /nix
mkdir /mnt/nix
mount -o subvol=@nix,"$BTRFS_OPTS" /dev/mapper/enc /mnt/nix

# /persist
mkdir /mnt/persist
mount -o subvol=@persist,"$BTRFS_OPTS" /dev/mapper/enc /mnt/persist

# /var/log
mkdir -p /mnt/var/log
mount -o subvol=@log,"$BTRFS_OPTS" /dev/mapper/enc /mnt/var/log

# do not forget to mount the boot partition
mkdir /mnt/boot
mount "$DISK"1 /mnt/boot

nixos-generate-config --root /mnt
