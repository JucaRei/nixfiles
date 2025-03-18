{ hostname, lib, pkgs, isInstall, config, ... }:

let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.system.scripts;

  # build-all = import ./build-all.nix { inherit pkgs; };
  build-host = import ./build-host.nix { inherit pkgs; };
  build-iso = import ./build-iso.nix { inherit pkgs; };
  flatpak-theme = import ./flatpak-theme.nix { inherit pkgs; };
  # switch-all = import ./switch-all.nix { inherit pkgs; };
  switch-host = import ./switch-host.nix { inherit pkgs; };
  switch-boot = import ./switch-boot.nix { inherit pkgs; };
  nixos-change-summary = import ./nixos-change-summary.nix { inherit pkgs; };
in
{
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
      nixos-change-summary
      # build-all
      build-host
      build-iso
      # switch-all
      switch-boot
      switch-host
    ] ++ lib.optionals (isInstall && config.services.flatpak.enable) [
      flatpak-theme
    ];
  };

}
