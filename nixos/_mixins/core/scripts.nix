{ hostname, lib, pkgs, isInstall, config, ... }:
let
  build-all = import ../../../resources/nixos/scripts/build-all.nix { inherit pkgs; };
  build-host = import ../../../resources/nixos/scripts/build-host.nix { inherit pkgs; };
  build-iso = import ../../../resources/nixos/scripts/build-iso.nix { inherit pkgs; };
  flatpak-theme = import ../../../resources/nixos/scripts/flatpak-theme.nix { inherit pkgs; };
  switch-all = import ../../../resources/nixos/scripts/switch-all.nix { inherit pkgs; };
  switch-host = import ../../../resources/nixos/scripts/switch-host.nix { inherit pkgs; };
  switch-boot = import ../../../resources/nixos/scripts/switch-boot.nix { inherit pkgs; };
in
{
  imports = [ ../../../resources/nixos/scripts/nixos-change-summary.nix ];
  environment.systemPackages = [
    build-all
    build-host
    build-iso
    switch-all
    switch-boot
    switch-host
  ] ++ lib.optionals (isInstall && config.services.flatpak.enable) [
    flatpak-theme
  ];
}