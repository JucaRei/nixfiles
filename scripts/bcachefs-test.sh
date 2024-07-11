#!/bin/sh

DRIVE="/dev/vda"

sgdisk -Z $DRIVE
# parted $DRIVE mklabel gpt
# parted $DRIVE mkpart primary 2048s 100%
parted --script --fix --align optimal $DRIVE mklabel gpt
parted --script --fix --align optimal $DRIVE mkpart primary fat32 1MiB 512MiB
parted --script $DRIVE -- set 1 boot on

# parted --script --align optimal -- $DRIVE mkpart primary 600MB 100%
# parted --script --align optimal --fix -- $DRIVE mkpart primary linux-swap -2GiB -1s
parted --script --align optimal --fix -- $DRIVE mkpart primary 512MiB -4GiB
parted --script --align optimal --fix -- $DRIVE mkpart primary linux-swap -4GiB 100%

# parted --script align-check 1 $DRIVE

# sgdisk -Z ${DRIVE}

sgdisk -c 1:"EFI FileSystem partition" ${DRIVE}
sgdisk -c 2:"Archlinux FileSystem" ${DRIVE}
sgdisk -c 3:"Archlinux Swap" ${DRIVE}
sgdisk -p ${DRIVE}

BOOT_PARTITION="${DRIVE}1"
ROOT_PARTITION="${DRIVE}2"
SWAP_PARTITION="${DRIVE}3"

### Format
mkfs.vfat -F 32 $BOOT_PARTITION -n "EFI"
mkfs.bcachefs $ROOT_PARTITION -f -L "Archlinux"
# mkfs.bcachefs format --compression=zstd:15  --fix_errors  --discard \
                # --encrypted                     \
                # --replicas=2                    \
                # --label=ssd.ssd1 /dev/sda       \
                # --label=vda.vda2 /dev/vda2       \
                # --label=ssd.ssd2 /dev/sdb       \
                # --label=hdd.hdd1 /dev/sdc       \
                # --label=hdd.hdd2 /dev/sdd       \
                # --label=hdd.hdd3 /dev/sde       \
                # --label=hdd.hdd4 /dev/sdf       \
                # --foreground_target=ssd         \
                # --promote_target=ssd            \
                # --background_target=hdd
                # --background_target=hdd

# sudo bcachefs format \
# --label hdd.hdd0 /dev/mapper/hdd0 \
# --label=ssd.ssd0 --discard --durability=2 /dev/mapper/ssd0 \
# --label ssd.ssd1 --discard --durability=2 /dev/mapper/ssd1 \
# --replicas=2 \
# --foreground_target=ssd --promote_target=ssd --background_target=hdd \
# --compression zstd:1 \
# --background_compression=zstd:15 \
# --acl \
# --data_checksum=crc32c \
# --metadata_checksum=crc32c

# bcachefs format --compression=zstd:15 /dev/vda2 -f -L "Archlinux"
# bcachefs format --discard --compression=zstd:15 /dev/vda2 -f -L "Archlinux"
bcachefs format --background_compression=zstd:15 --compression=lz4:3 --discard /dev/vda2 -f -L "Archlinux"

bcachefs format -f --fs_label=root --label=root --encrypted /dev/vda2

mkswap $SWAP_PARTITION -L "SWAP"
swapon /dev/disk/by-label/SWAP

BCACHE_OPTS="bind,relatime,nodiratime,compression=zstd:15,discard"

# background_compression

# BCACHE_OPTS="rw,noatime,ssd,compress-force=zstd:15,space_cache=v2,commit=120,discard=async"
mount  -o $BCACHE_OPTS --bind /dev/disk/by-label/Archlinux /mnt
# bcachefs subvolume create /mnt/@
bcachefs subvolume create /mnt/home
bcachefs subvolume create /mnt/pacman
mkdir -pv /mnt/var
bcachefs subvolume create /mnt/var/cache
bcachefs subvolume create /mnt/var/log
bcachefs subvolume create /mnt/var/tmp
bcachefs subvolume create /mnt/snapshots
# bcachefs subvolume create /mnt/@swap
umount -Rv /mnt

bcachefs mount -o relatime,nodiratime,background_compression=lz4:0,compression=lz4:1,discard /dev/disk/by-label/root /mnt
mount -o umask=0077 /dev/disk/by-label/EFI /mnt/boot


# mount -o $BCACHE_OPTS,subvol=@root /dev/vda2 /mnt
mount -o $BCACHE_OPTS,subvol= /dev/disk/by-label/Archlinux /mnt
mount -o $BCACHE_OPTS,subvol="home" /dev/disk/by-label/Archlinux /mnt/home
mount -o $BCACHE_OPTS,subvol="snapshots" /dev/disk/by-label/Archlinux /mnt/.snapshots
mount -o $BCACHE_OPTS,subvol="logs" /dev/disk/by-label/Archlinux /mnt/var/log
mount -o $BCACHE_OPTS,subvol="cache" /dev/disk/by-label/Archlinux /mnt/var/cache
mount -o $BCACHE_OPTS,subvol="tmp" /dev/disk/by-label/Archlinux /mnt/var/tmp
# mount -o defaults,noatime,subvol="@swap" /dev/disk/by-label/Archlinux /mnt/swap
mount -t vfat -o defaults,noatime,nodiratime /dev/disk/by-label/Grub /mnt/boot/efi

pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware archlinux-keyring man-db perl sysfsutils python python-pip git man-pages dropbear git nano neovim intel-ucode fzf duf reflector mtools dosfstools btrfs-progs pacman-contrib nfs-utils --ignore linux vi
