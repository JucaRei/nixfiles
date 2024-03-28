{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.services.atuin;
in
{
  options.services.atuin = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = {
    programs = {
      atuin = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        flags = [ "--disable-up-arrow" ];
        package = pkgs.atuin;
        settings = {
          auto_sync = true;
          dialect = "us";
          # key_path = config.sops.secrets.atuin_key.path;
          show_preview = true;
          style = "compact";
          sync_frequency = "1h";
          sync_address = "https://api.atuin.sh";
          update_check = false;
        };
      };
    };
  };
}
