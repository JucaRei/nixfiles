#!/usr/bin/env bash
# Test script for flake

set -eu

echo "Running nix flake check..."
nix flake check --extra-experimental-features nix-command --extra-experimental-features flakes

echo "All tests passed!"
