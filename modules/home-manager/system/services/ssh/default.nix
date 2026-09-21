{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool listOf str;
  cfg = config.system.services.ssh;
in
{
  options = {
    system.services.ssh = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable ssh configs.";
      };

      identityFiles = mkOption {
        type = listOf str;
        default = [
          "~/.ssh/nitro"
          "~/.ssh/id_ed25519"
          "~/.ssh/id_rsa"
        ];
        description = "SSH IdentityFiles to load by default.";
      };
    };
  };
  config = mkIf cfg.enable {
    programs = {
      ssh = {
        enable = true;
        settings = {
          "*" = {
            Compression = true;
            ForwardAgent = true;
            ControlMaster = "auto";
            IdentityFile = cfg.identityFiles;
          };
        };

        # extraConfig = "Banner ${./banner.txt}";
      };
    };
  };
}
