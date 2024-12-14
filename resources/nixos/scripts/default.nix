{ hostname, lib, pkgs, isInstall, config, ... }:
let
  build-all = import ./build-all.nix { inherit pkgs; };
  build-host = import ./build-host.nix { inherit pkgs; };
  build-iso = import ./build-iso.nix { inherit pkgs; };
  flatpak-theme = import ./flatpak-theme.nix { inherit pkgs; };
  switch-all = import ./switch-all.nix { inherit pkgs; };
  switch-host = import ./switch-host.nix { inherit pkgs; };
  switch-boot = import ./switch-boot.nix { inherit pkgs; };
in
{
  imports = [ ./nixos-change-summary.nix ];
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
