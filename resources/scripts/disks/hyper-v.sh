#!/usr/bin/env bash

export DISK=/dev/sda
sudo parted $DISK --script \
  unit MiB \
  mklabel gpt \
  mkpart ESP fat32 1 513 \
  set 1 boot on \
  mkpart swap linux-swap 513 8705 \
  mkpart nix 8705 100% \
  print

Check alignment:
for i in {1..3}; do sudo parted $DISK -- align-check optimal $i; done

# The following will set variables PART1, PART2, and PART3
# to the partition names. I realized when trying this out
# on a laptop with a NVMe drive that simply using ${DISK}1
# wouldn't work when the disk ends with a number such as nvme0n1,
# the partitions end up looking like nvme0n1p1 etc.

for i in {1..3}; do
  export "PART$i"=$(lsblk -lp | grep part | grep ${DISK} | awk -v line=$i 'NR==line{print $1}')
done
echo $PART1
echo $PART2
echo $PART3

## Luks encrypt the root partition:
cryptsetup luksFormat $PART3

# Open the encrypted partition and change the variable to point to the
# decrypted partition:
cryptsetup luksOpen $PART3 crypted &&
  export PART3=/dev/mapper/crypted

## Format Partitions

mkfs.fat -F 32 -n boot ${PART1} &&
  mkswap -L swap ${PART2} &&
  mkfs.ext4 -L nixos ${PART3}

# Visually verify the partitions and file systems using:
parted $DISK -- unit MiB print

## I'm going to base the following on the excellent https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/ guide.
#!/usr/bin/env bash

set -e

# cat <<'EOF' >~/mount.sh
# Mount your root file system as tmpfs
mount -v -t tmpfs none /mnt

# Create mount directories
mkdir -v -p /mnt/{boot,nix,etc/nixos,var/log}

# Mount /boot and /nix
mount -v $PART1 /mnt/boot -o umask=0077
mount -v $PART3 /mnt/nix

# Create persistent directories
mkdir -v -p /mnt/nix/persist/{etc/nixos,var/log}

# Bind mount the persistent configuration / logs
mount -v -o bind /mnt/nix/persist/etc/nixos /mnt/etc/nixos
mount -v -o bind /mnt/nix/persist/var/log /mnt/var/log

# Make config directory temporarily easier to work with
chmod -v 777 /mnt/etc/nixos

# EOF

# chmod u+x ~/mount.sh && sudo -E ~/mount.sh

# mount: none mounted on /mnt.
# mkdir: created directory '/mnt/boot'
# mkdir: created directory '/mnt/nix'
# mkdir: created directory '/mnt/etc'
# mkdir: created directory '/mnt/etc/nixos'
# mkdir: created directory '/mnt/var'
# mkdir: created directory '/mnt/var/log'
# mount: /mnt/boot: can't find in /etc/fstab.

swapon $PART2

nixos-generate-config --root /mnt && cd /mnt/etc/nixos

## default units for `print` and `mkpart` commands
# unit MiB
## initialize the partition table
# mklabel gpt
## Make boot partition 512 MiB.
## Note that 1MiB is where my partition needs to start for optimal alignment.
# mkpart ESP fat32 1 513
## mark the partition is bootable
# set 1 boot on
## Make swap partition 8705 = 513 + 8192 (note 8192MiB = 8GiB)
# mkpart swap linux-swap 513 8705
## Make root partition the rest of the drive
# mkpart nix 8705 100%
## see the results
# print

# nix-shell -p openssh_hpn

# scp nixos@192.168.1.103:/mnt/etc/nixos/configuration.nix /mnt/c/Users/juca/Documents/workspace/nixfiles/nixos/hosts/hyperv

# sed -i '/fsType = "tmpfs";/a options = [ "defaults" "size=25%" "mode=755" ];' \
#   ./hardware-configuration.nix && \
#   nix-shell -p nixpkgs-fmt --run 'nixpkgs-fmt .'

# cat <<EOF >~/encrypted-swap.sh
###  !/usr/bin/env bash

for i in {1..3}; do
  export "PART$i"=$(lsblk -lp | grep part | grep ${DISK} | awk -v line=$i 'NR==line{print $1}')
done
echo $PART1
echo $PART2
echo $PART3

set -e

if [[ -z $PART2 ]]; then
  echo "PART2 is undefined or empty"
  exit 1
fi

hwConfig=/mnt/etc/nixos/hardware-configuration.nix
backupHwConfig=/mnt/etc/nixos/hardware-configuration.backup.nix

main() {
  swapPart=$(echo $PART2 | awk -F'/' '{print $NF}')
  swapDiskUUID=$(ls -l /dev/disk/by-uuid | grep $swapPart | awk '{print $9}')
  swapPartUUID=$(ls -l /dev/disk/by-partuuid | grep $swapPart | awk '{print $9}')

  echo "swapDiskUUID: $swapDiskUUID"
  echo "swapPartUUID: $swapPartUUID"

  sed -i "s|by-uuid/$swapDiskUUID|by-partuuid/$swapPartUUID|g" $hwConfig
  sed -i "/$swapPartUUID/s/\";/\";\n/" $hwConfig
  sed -i "/$swapPartUUID\"/ a\\randomEncryption.enable = true;" $hwConfig

  nix-shell -p nixpkgs-fmt --run "nixpkgs-fmt $hwConfig"
}

cp $hwConfig $backupHwConfig
trap 'cp $backupHwConfig $hwConfig' ERR
main
# EOF

# chmod u+x ~/encrypt-swap.sh && ~/encrypt-swap.sh

# nix-shell --run 'mkpasswd -m SHA-512 -s' -p mkpasswd

# NIX_CONFIG="experimental-features = nix-command flakes" \
# sudo nixos-install --flake .#hyperv
