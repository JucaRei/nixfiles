{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool;
  cfg = config.hardware.storage;
in
{
  options.hardware.storage = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Whether or not to enable support for extra storage devices.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ntfs3g
      fuseiso
    ];
  };
}
