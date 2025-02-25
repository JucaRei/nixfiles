{ hostname, isISO, config, lib, pkgs, ... }:
let
  installOn = [
    "minimech"
    "scrubber"
  ];
  inherit (lib) mkOption mkIf elem mkOverride types;
  cfg = config.system.services.bcachefs;
in
{
  options = {
    system.services.bcachefs = {
      enable = mkOption {
        type = types.bool;
        default = if (elem hostname installOn || isISO) then true else false;
        description = "Enables bcachefs filesystem.";
      };
    };
  };

  config = mkIf cfg.enable {
    # Create a bootable ISO image with bcachefs.
    # - https://wiki.nixos.org/wiki/Bcachefs
    boot = {
      kernelPackages = mkOverride 0 pkgs.linuxPackages_latest;
      supportedFilesystems = [ "bcachefs" ];
    };
    environment.systemPackages = with pkgs; [
      bcachefs-tools
      keyutils
    ];
  };
}
