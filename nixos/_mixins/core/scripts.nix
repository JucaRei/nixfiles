{ hostname, lib, pkgs, isInstall, config, ... }:
let
  build-all = import ../../../resources/nixos/scripts2/build-all.nix { inherit pkgs; };
  build-host = import ../../../resources/nixos/scripts2/build-host.nix { inherit pkgs; };
  build-iso = import ../../../resources/nixos/scripts2/build-iso.nix { inherit pkgs; };
  flatpak-theme = import ../../../resources/nixos/scripts2/flatpak-theme.nix { inherit pkgs; };
  switch-all = import ../../../resources/nixos/scripts2/switch-all.nix { inherit pkgs; };
  switch-host = import ../../../resources/nixos/scripts2/switch-host.nix { inherit pkgs; };
  switch-boot = import ../../../resources/nixos/scripts2/switch-boot.nix { inherit pkgs; };
in
{
  imports = [
    ../../../resources/nixos/scripts
  ];
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
