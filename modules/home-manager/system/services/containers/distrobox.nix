{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf getExe';
  inherit (lib.types) bool;
  cfg = config.system.services.containers.distrobox;
in
{
  options = {
    system.services.containers.distrobox = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable's distrobox";
      };
    };
  };
  config = mkIf cfg.enable {
    home = {
      package = pkgs.distrobox;
      file = {
        ".distroboxrc".text = ''${getExe' pkgs.xorg.xhost "xhost"} +si:localuser:$USER'';
      };
    };
  };
}
