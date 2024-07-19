#!/bin/sh

# export DRIVE="/dev/nvme0n1"
# DRIVE="/dev/nvme0n1p2"
DRIVE="/dev/mmcblk0"

sgdisk -Z ${DRIVE}
parted --script --fix --align optimal $DRIVE mklabel gpt
parted --script --fix --align optimal $DRIVE mkpart primary fat32 1MiB 512MiB
parted --script $DRIVE -- set 1 boot on
parted --script --align optimal --fix -- $DRIVE mkpart primary 512MiB -6GiB
parted --script --align optimal --fix -- $DRIVE mkpart primary linux-swap -6GiB 100%

sgdisk -c 1:"EFI FileSystem partition" ${DRIVE}
sgdisk -c 2:"NixOS FileSystem" ${DRIVE}
sgdisk -c 3:"NixOS Swap" ${DRIVE}
sgdisk -p ${DRIVE}

BOOT_PARTITION="${DRIVE}p1"
ROOT_PARTITION="${DRIVE}p2"
SWAP_PARTITION="${DRIVE}p3"

mkfs.vfat -F32 $BOOT_PARTITION -n "EFI"
mkfs.btrfs $ROOT_PARTITION -f -L "Soyos"
mkswap $SWAP_PARTITION -L "SWAP"
swapon /dev/disk/by-label/SWAP

BTRFS_OPTS="rw,noatime,ssd,compress-force=zstd:15,space_cache=v2,nodatacow,commit=120,discard=async"
BTRFS_OPTS2="rw,noatime,ssd,compress-force=zstd:3,space_cache=v2,nodatacow,commit=120,discard=async"
# BTRFS_OPTS="rw,noatime,ssd,compress-force=zstd:15,space_cache=v2,commit=120,discard=async"
mount -o $BTRFS_OPTS /dev/disk/by-label/Soyos /mnt
btrfs su cr /mnt/@rootfs
btrfs su cr /mnt/@home
btrfs su cr /mnt/@nix
btrfs su cr /mnt/@logs
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@snapshots
btrfs su cr /mnt/@swap
umount -Rv /mnt

# mount -o $BTRFS_OPTS,subvol=@root /dev/vda2 /mnt
mount -o $BTRFS_OPTS2,subvol=@rootfs /dev/disk/by-label/Soyos /mnt
# mount -o $BTRFS_OPTS,subvol="@root" /dev/disk/by-partlabel/Soyos /mnt
# mkdir -pv /mnt/{boot/efi,home,.snapshots,nix,var/log,var/tmp,var/swap}
mkdir -pv /mnt/{boot,home,.snapshots,nix,var/{swap,tmp,log}}
mount -o $BTRFS_OPTS,subvol=@home /dev/disk/by-label/Soyos /mnt/home
# mount -o $BTRFS_OPTS,subvol="@home" /dev/disk/by-partlabel/Soyos /mnt/home
mount -o $BTRFS_OPTS,subvol=@snapshots /dev/disk/by-label/Soyos /mnt/.snapshots
# mount -o $BTRFS_OPTS,subvol="@snapshots" /dev/disk/by-partlabel/Soyos /mnt/.snapshots
mount -o $BTRFS_OPTS,subvol=@tmp /dev/disk/by-label/Soyos /mnt/var/tmp
# mount -o $BTRFS_OPTS,subvol="@tmp" /dev/disk/by-partlabel/Soyos /mnt/var/tmp
mount -o $BTRFS_OPTS,subvol=@nix /dev/disk/by-label/Soyos /mnt/nix
mount -o $BTRFS_OPTS,subvol=@logs /dev/disk/by-label/Soyos /mnt/var/log
mount -o $BTRFS_OPTS,subvol=@swap /dev/disk/by-label/Soyos /mnt/var/swap
# mount -o $BTRFS_OPTS,subvol="@nix" /dev/disk/by-partlabel/Soyos /mnt/nix
mount /dev/disk/by-label/BOOT /mnt/boot
mkdir -pv /mnt/boot/efi
mount -t vfat -o defaults,noatime,nodiratime /dev/disk/by-label/EFI /mnt/boot/efi

touch /mnt/var/swap/swapfile
chmod 600 /mnt/var/swap/swapfile
chattr +C /mnt/var/swap/swapfile
lsattr /mnt/var/swap/swapfile
dd if=/dev/zero of=/mnt/var/swap/swapfile bs=1M count=6144 status=progress
mkswap /mnt/var/swap/swapfile
swapon /mnt/var/swap/swapfile



# for dir in dev proc sys run; do
#    mount --rbind /$dir /mnt/$dir
#    mount --make-rslave /mnt/$dir
# done

# UEFI_UUID=$(blkid -s UUID -o value /dev/vda1)
# ROOT_UUID=$(blkid -s UUID -o value /dev/vda2)

# mkdir -pv /home/NIXOS/.config/nix/
# touch /home/NIXOS/.config/nix/nix.conf
# echo "experimental-features = nix-command flakes" >> /home/NIXOS/.config/nix/nix.conf

# NIXOS-generate-config --root /mnt
# nix.settings.experimental-features = [ "nix-command" "flakes" ];

# nix-env -iA NIXOS.git

# git clone --depth=1 https://github.com/JucaRei/teste-repo /home/NIXOS/.setup
# git clone --depth=1 https://github.com/JucaRei/NIXOS-conf /home/NIXOS/.setup

## Install flake repo
# sudo NIXOS-install -v --root /mnt --impure --flake /home/NIXOS/.setup#vm
# sudo NIXOS-install -v --root /mnt --impure --flake github:JucaRei/NIXOS-conf#vm
# sudo NIXOS-install -v --root /mnt --impure --flake .#mcbair
# sudo NIXOS-rebuild --flake /home/NIXOS/.setup#vm
# sudo NIXOS-rebuild switch --flake /home/NIXOS/.setup#vm
# sudo NIXOS-rebuild switch --flake /home/NIXOS/.setup#vm --fallback

## Chroot

# NIXOS-enter --root /mnt                             # Start an interactive shell in the NIXOS installation in /mnt
# NIXOS-enter -c 'ls -l /; cat /proc/mounts'          # Run a shell command
# NIXOS-enter -- cat /proc/mounts                     # Run a non-shell command

# nix flake check --no-build github:NIXOS/patchelf

## Check dots
# nix flake check --no-build github:JucaRei/NIXOS-conf#vm --extra-experimental-features nix-command --extra-experimental-features flakes
# nix flake check --no-build --no-write-lock-file github:JucaRei/NIXOS-conf --extra-experimental-features nix-command --extra-experimental-features flakes
# nix flake check --no-build --no-write-lock-file --show-trace github:JucaRei/NIXOS-conf --extra-experimental-features nix-command --extra-experimental-features flakes
