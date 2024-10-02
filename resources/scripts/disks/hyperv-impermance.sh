#!/usr/bin/env bash

disk = "/dev/sda"


parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 1GiB
parted /dev/sda -- set 1 boot on
mkfs.vfat /dev/sda1 -n "BOOT"

# As I intend to use this VM on Proxmox, I will not encrypt the {disk}

# parted /dev/sda -- mkpart Swap linux-swap 1GiB 9GiB
# mkswap -L Swap ${disk2}
# swapon ${disk2}

# parted /dev/sda -- mkpart primary 9GiB 100%
parted /dev/sda -- mkpart primary 1GiB 100%
# mkfs.btrfs -L Nixos ${disk3}
mkfs.btrfs -L NIXOS /dev/sda2

# mount ${disk3} /mnt
mount /dev/disk/by-label/NIXOS /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@persist
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@swap

# We then take an empty *readonly* snapshot of the root subvolume,
# which we'll eventually rollback to on every boot.
btrfs subvolume snapshot -r /mnt/@ /mnt/@-blank

umount /mnt

# Mount the directories

# mount -o subvol=root,compress=zstd,noatime ${disk3} /mnt
mount -o subvol=@,compress=zstd,noatime /dev/disk/by-label/NIXOS /mnt
mkdir -pv /mnt/{boot,home,persist,nix,var/{swap,log}}

mount -o subvol=@home,compress=zstd,noatime /dev/disk/by-label/NIXOS /mnt/home
mount -o subvol=@nix,compress=zstd,noatime /dev/disk/by-label/NIXOS /mnt/nix
mount -o subvol=@persist,compress=zstd,noatime /dev/disk/by-label/NIXOS /mnt/persist
mount -o subvol=@log,compress=zstd,noatime /dev/disk/by-label/NIXOS /mnt/var/log
mount -o subvol=@swap,compress=zstd,noatime /dev/disk/by-label/NIXOS /mnt/var/swap

touch /mnt/var/swap/swapfile
chmod 600 /mnt/var/swap/swapfile
chattr +C /mnt/var/swap/swapfile
lsattr /mnt/var/swap/swapfile
# dd if=/dev/zero of=/mnt/var/swap/swapfile bs=1M count=4096 status=progress
dd if=/dev/zero of=/mnt/var/swap/swapfile bs=1M count=5120 status=progress
mkswap /mnt/var/swap/swapfile
swapon /mnt/var/swap/swapfile

# don't forget this!
mount /dev/disk/by-label/BOOT /mnt/boot

# create configuration
nixos-generate-config --root /mnt

# now, edit nixos configuration and nixos-install
