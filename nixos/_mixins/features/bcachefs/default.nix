{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.features.bcachefs;
in
{
  options.features.bcachefs = {
    enable = mkEnableOption "Whether enable bcachefs filesystem support tools.";
  };

  config = mkIf cfg.enable {
    # Enable filesystem support for Bcachefs
    boot.supportedFilesystems = [ "bcachefs" ];

    # Specify the file system configuration
    fileSystems."/" = {
      device = "/dev/sda1"; # Replace with your device identifier
      fsType = "bcachefs";
      options = [ "compression=zstd" ]; # Example option, adjust as needed
    };

    # Use the latest Linux kernel supporting Bcachefs
    #boot.kernelPackages = pkgs.linuxPackages_latest;

    # Include bcachefs-tools
    environment.systemPackages = with pkgs; [
      bcachefs-tools
    ];

    # Additional configurations can be added here
  };
}
