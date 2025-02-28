{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.programs.terminal.console.yazi;
in
{
  options.programs.terminal.console.yazi = {
    enable = mkOption {
      default = false;
      type = bool;
      description = "Enable's Yazi.";
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
        "${config.xdg.configHome}/yazi/keymap.toml".text = builtins.readFile ./confs/yazi-keymap.toml;
        "${config.xdg.configHome}/yazi/theme.toml".text = builtins.readFile ./confs/yazi-theme.toml;
      };
    };
  };
}
