{ config, lib, ... }:
let
  inherit (lib) mkOption types mkIf;
  cfg = config.console.yazi;
in
{
  options.console.yazi = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs = {
      yazi = {
        enable = false;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        settings = {
          manager = {
            show_hidden = false;
            show_symlink = true;
            sort_by = "natural";
            sort_dir_first = true;
            sort_sensitive = false;
            sort_reverse = false;
          };
        };
      };
    };
    home = {
      file = {
        "${config.xdg.configHome}/yazi/keymap.toml".text = builtins.readFile ../../../dots/yazi/yazi-keymap.toml;
        "${config.xdg.configHome}/yazi/theme.toml".text = builtins.readFile ../../../dots/yazi/yazi-theme.toml;
      };
    };
  };
}
