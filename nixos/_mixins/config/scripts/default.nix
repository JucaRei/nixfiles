{ hostname, lib, pkgs, isInstall, config, ... }:
let
  build-all = import ./build-all.nix { inherit pkgs; };
  build-host = import ./build-host.nix { inherit pkgs; };
  build-iso = import ./build-iso.nix { inherit pkgs; };
  flatpak-theme = import ./flatpak-theme.nix { inherit pkgs; };
  purge-gpu-caches = import ./purge-gpu-caches.nix { inherit pkgs; };
  simple-password = import ./simple-password.nix { inherit pkgs; };
  switch-all = import ./switch-all.nix { inherit pkgs; };
  # boot-host = import ./boot-host.nix { inherit pkgs; };
  switch-host = import ./switch-host.nix { inherit pkgs; };
  switch-boot = import ./switch-boot.nix { inherit pkgs; };
  unroll-url = import ./unroll-url.nix { inherit pkgs; };
in
{
  imports = [ ./nixos-change-summary.nix ];
  environment.systemPackages = [
    build-all
    build-host
    build-iso
    purge-gpu-caches
    simple-password
    switch-all
    # boot-host
    switch-boot
    switch-host
    unroll-url
  ] ++ lib.optionals (isInstall && config.services.flatpak.enable) [
    flatpak-theme
  ];
}
