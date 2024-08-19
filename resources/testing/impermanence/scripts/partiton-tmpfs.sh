#!/usr/bin/env bash

export DISK=/dev/vda


sudo sgdisk -Z /dev/vda

sudo parted $DISK --script \
  unit MiB \
  mklabel gpt \
  mkpart ESP fat32 1 513 \
  set 1 boot on \
  mkpart swap linux-swap 513 8705 \
  mkpart nix 8705 100% \
  print

# Check alignment:
  for i in {1..3}; do sudo parted $DISK -- align-check optimal $i; done

  for i in {1..3};\
  do export "PART$i"=$(lsblk -lp | grep part | grep ${DISK} | awk -v line=$i 'NR==line{print $1}');\
done;\
echo $PART1; echo $PART2; echo $PART3

sudo cryptsetup luksFormat $PART3

sudo cryptsetup luksOpen $PART3 crypted && \
  export PART3=/dev/mapper/crypted


sudo mkfs.fat -F 32 -n boot ${PART1} && \
  sudo mkswap -L swap ${PART2} && \
  sudo mkfs.ext4 -L nixos ${PART3}
  # sudo mkfs.btrfs -f -L nixos ${PART3}

sudo parted $DISK -- unit MiB print

# # default units for `print` and `mkpart` commands
# unit MiB
# # initialize the partition table
# mklabel gpt
# # Make boot partition 512 MiB.
# # Note that 1MiB is where my partition needs to start for optimal alignment.
# mkpart ESP fat32 1 513
# # mark the partition is bootable
# set 1 boot on
# # Make swap partition 8705 = 513 + 8192 (note 8192MiB = 8GiB)
# mkpart swap linux-swap 513 8705
# # Make root partition the rest of the drive
# mkpart nix 8705 100%
# # see the results
# print


### Mount ###


set -e

# Mount your root file system as tmpfs
sudo mount -v -t tmpfs none /mnt

# Create mount directories
sudo mkdir -v -p /mnt/{boot,nix,etc/nixos,var/log}

# Mount /boot and /nix
sudo mount -v $PART1 /mnt/boot -o umask=0077
sudo mount -v $PART3 /mnt/nix

# Create persistent directories
sudo mkdir -v -p /mnt/nix/persist/{etc/nixos,var/log}

# Bind mount the persistent configuration / logs
sudo mount -v -o bind /mnt/nix/persist/etc/nixos /mnt/etc/nixos
sudo mount -v -o bind /mnt/nix/persist/var/log /mnt/var/log

# Make config directory temporarily easier to work with
sudo chmod -v 777 /mnt/etc/nixos


sudo swapon $PART2

sudo nixos-generate-config --root /mnt && cd /mnt/etc/nixos
