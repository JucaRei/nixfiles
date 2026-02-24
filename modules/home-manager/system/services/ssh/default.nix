{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.services.ssh;
in
{
  options = {
    system.services.ssh = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's ssh configs.";
      };
    };
  };
  config = mkIf cfg.enable {
    programs = {
      ssh = {
        enable = true;
        compression = true;
        forwardAgent = true;
        controlMaster = "auto";
        extraConfig = "Banner ${./banner.txt}";
      };
    };
  };
}
