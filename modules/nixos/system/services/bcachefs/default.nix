{
  isISO,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    types
    ;
  cfg = config.nixos.services.bcachefs;
in
{
  options = {
    nixos.services.bcachefs = {
      enable = mkOption {
        type = types.bool;
        default = isISO;
        description = "Enables bcachefs filesystem.";
      };
    };
  };

  config = mkIf cfg.enable {
    # Create a bootable ISO image with bcachefs.
    # - https://wiki.nixos.org/wiki/Bcachefs
    boot = {
      supportedFilesystems = [ "bcachefs" ];
    };
    environment.systemPackages = with pkgs; [
      bcachefs-tools
      keyutils
    ];
  };
}
