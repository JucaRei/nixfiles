# lib/nixpkgs-config.nix
# Unified canonical configuration of nixpkgs for NixOS and Home Manager.
# Insecure or broken packages must not be enabled globally.
{
  allowUnfree = true;
  nvidia.acceptLicense = true;
}
