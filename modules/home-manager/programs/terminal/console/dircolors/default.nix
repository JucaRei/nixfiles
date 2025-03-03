{ lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.programs.terminal.console.dircolors;
in
{
  options.programs.terminal.console.dircolors = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    programs.dircolors = {
      settings = {
        # Files that I don't have to pay attention to
        ".nfo" = "90";
        ".sfv" = "90";
        ".srt" = "90";
        ".sub" = "90";
      };
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      # extraConfig = builtins.readFile ./LS_COLORS_catppuccin;
      extraConfig = builtins.readFile ./LS_COLORS_solarized-dark;
    };
  };
}
