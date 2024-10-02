cat << 'EOF' > ~/mount.sh
#!/usr/bin/env bash

set -e

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

EOF

chmod u+x ~/mount.sh && sudo -E ~/mount.sh
