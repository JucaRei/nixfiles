_:
# { lib, pkgs, isInstall, config, ... }:
# let
#   build-host = import ../../../../resources/nixos/scripts/build-host.nix { inherit pkgs; };
#   build-iso = import ../../../../resources/nixos/scripts/build-iso.nix { inherit pkgs; };
#   flatpak-theme = import ../../../../resources/nixos/scripts/flatpak-theme.nix { inherit pkgs; };
#   switch-host = import ../../../../resources/nixos/scripts/switch-host.nix { inherit pkgs; };
#   switch-boot = import ../../../../resources/nixos/scripts/switch-boot.nix { inherit pkgs; };
# in
{
  imports = [
    ../../../../resources/nixos/scripts
  ];
  # environment.systemPackages = [
  #   build-host
  #   build-iso
  #   switch-boot
  #   switch-host
  # ] ++ lib.optionals (isInstall && config.services.flatpak.enable) [
  #   flatpak-theme
  # ];
}
