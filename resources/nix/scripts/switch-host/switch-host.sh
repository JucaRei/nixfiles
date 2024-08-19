#!/usr/bin/env bash

if [ -e "${HOME}/.dotfiles/nixfiles" ]; then
    all_cores=$(nproc)
    build_cores=$(printf "%.0f" "$(echo "${all_cores} * 0.75" | bc)")
    echo "Switch nix-darwin ❄️ with ${build_cores} cores"
    nix run nix-darwin -- switch --flake "${HOME}/.dotfiles/nixfiles" --cores "${build_cores}" -L
else
    echo "ERROR! No nix-config found in ${HOME}/.dotfiles/nixfiles"
fi
