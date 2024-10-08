#!/usr/bin/env bash

set -e

# Install Nix (single user mode)
# NOTE: if installing on a system multiple people will be using, manually
#       install the multi-user installation instead.
# See: https://nixos.org/manual/nix/stable/installation/installing-binary.html#single-user-installation

if [[ ! -e /nix/store ]]; then
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    . $HOME/.nix-profile/etc/profile.d/nix.sh
fi

./install.sh

echo 'Adding you to the "docker" group...'
sudo usermod -aG docker $USER
