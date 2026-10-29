{
  isISO,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    ;
  cfg = config.nixos.services.bcachefs;
in
{
  options = {
    nixos.services.bcachefs = {
      enable = lib.my.mkBool isISO "Enables bcachefs filesystem.";
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
