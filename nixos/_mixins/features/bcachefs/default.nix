{ hostname, isISO, lib, pkgs, ... }:
let
  installOn = [
    "minimech"
    "scrubber"
  ];
  inherit (lib) mkOption mkIf elem mkOverride types;

in
{
  options = {
    features.bcachefs = {
      enable = mkOption {
        type = types.bool;
        default = mkIf (elem hostname installOn || isISO);
        description = "Enables bcachefs filesystem.";
      };
    };
  };

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
}
