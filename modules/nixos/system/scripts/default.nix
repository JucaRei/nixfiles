{ hostname, lib, pkgs, isInstall, config, ... }:

let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.system.scripts;

  build-all = import ../../../../resources/nixos/scripts/build-all.nix { inherit pkgs; };
  build-host = import ../../../../resources/nixos/scripts/build-host.nix { inherit pkgs; };
  build-iso = import ../../../../resources/nixos/scripts/build-iso.nix { inherit pkgs; };
  flatpak-theme = import ../../../../resources/nixos/scripts/flatpak-theme.nix { inherit pkgs; };
  switch-all = import ../../../../resources/nixos/scripts/switch-all.nix { inherit pkgs; };
  switch-host = import ../../../../resources/nixos/scripts/switch-host.nix { inherit pkgs; };
  switch-boot = import ../../../../resources/nixos/scripts/switch-boot.nix { inherit pkgs; };
in
{
  imports = [ ../../../../resources/nixos/scripts/nixos-change-summary.nix ];
  options = {
    system = {
      scripts = {
        enable = mkOption {
          type = bool;
          default = false;
          description = "Enable system scripts.";
        };
      };
    };
  };
  config = mkIf cfg.enable {
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
  };

}
