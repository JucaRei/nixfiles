{
  hostname,
  isISO,
  config,
  lib,
  pkgs,
  ...
}:
let
  installOn = [
    "nitro"
  ];
  inherit (lib)
    mkOption
    mkIf
    elem
    types
    ;
  cfg = config.nixos.services.bcachefs;
in
{
  options = {
    nixos.services.bcachefs = {
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
      supportedFilesystems = [ "bcachefs" ];
    };
    environment.systemPackages = with pkgs; [
      bcachefs-tools
      keyutils
    ];
  };
}
