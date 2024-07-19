export DRIVE="/dev/nvme0n1"
export BOOT_PARTITION="${DRIVE}p2"
export ROOT_PARTITION="${DRIVE}p3"

BTRFS_OPTS="rw,noatime,ssd,compress-force=zstd:15,space_cache=v2,nodatacow,commit=120,discard=async"
mount -o $BTRFS_OPTS,subvol="@" /dev/disk/by-label/NIXOS /mnt
mount -o $BTRFS_OPTS,subvol="@home" /dev/disk/by-label/Nitroux /mnt/home
# mount -o $BTRFS_OPTS,subvol="@home" /dev/disk/by-partlabel/Nitroux /mnt/home
mount -o $BTRFS_OPTS,subvol="@snapshots" /dev/disk/by-label/Nitroux /mnt/.snapshots
# mount -o $BTRFS_OPTS,subvol="@snapshots" /dev/disk/by-partlabel/Nitroux /mnt/.snapshots
mount -o $BTRFS_OPTS,subvol="@tmp" /dev/disk/by-label/Nitroux /mnt/var/tmp
# mount -o $BTRFS_OPTS,subvol="@tmp" /dev/disk/by-partlabel/Nitroux /mnt/var/tmp
mount -o $BTRFS_OPTS,subvol="@nix" /dev/disk/by-label/Nitroux /mnt/nix
mount -o $BTRFS_OPTS,subvol=@logs /dev/disk/by-label/Nitroux /mnt/var/log
# mount -o $BTRFS_OPTS,subvol="@nix" /dev/disk/by-partlabel/Nitroux /mnt/nix
mount -t vfat -o defaults,noatime,nodiratime /dev/disk/by-label/GRUB /mnt/boot/efi

nixos-enter
