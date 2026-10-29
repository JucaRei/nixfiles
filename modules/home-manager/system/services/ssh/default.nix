{ lib, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.system.services.ssh;
in
{
  options = {
    system.services.ssh = {
      enable = lib.my.mkBool false "Enable ssh configs.";

      identityFiles = lib.my.mkListOf lib.types.str [
        "~/.ssh/nitro"
        "~/.ssh/id_ed25519"
        "~/.ssh/id_rsa"
      ] "SSH IdentityFiles to load by default.";
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
