{ pkgs, config, lib, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.custom.console.atuin;
in
{
  options.custom.console.atuin = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
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
