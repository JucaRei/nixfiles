{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf getExe;
  inherit (lib.types) bool;
  cfg = config.system.programs.console.eza;
in
{
  options = {
    system.programs.console.eza = {
      enable = mkOption {
        default = false;
        type = bool;
        description = "Enable's eza.";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.eza = {
      enable = true;
      git = true;
      icons = "auto";
      colors = "always";
      enableBashIntegration = mkIf (config.system.programs.shells.default == "bash") true;
      enableFishIntegration = mkIf (config.system.programs.shells.default == "fish") true;
      enableZshIntegration = mkIf (config.system.programs.shells.default == "zsh") true;
      extraOptions = [
        "--color=always"
        "--icons"
        "--group-directories-first"
        "--header"
        "--time-style=long-iso"
        "-l"
      ];
    };
    home = {
      shellAliases = {
        l2 = "${getExe config.programs.eza.package} --color=always --icons --header --time-style=long-iso -l -T -h -L=2";
        lt = "${getExe config.programs.eza.package} --color=always --icons --header --time-style=long-iso -a -h";
        lla = "${getExe config.programs.eza.package} --color=always --icons --header --time-style=long-iso -l -a";
        tree = "${getExe config.programs.eza.package} --color=always --icons --header --time-style=long-iso --tree -l";
        la = "${getExe config.programs.eza.package} --color=always --icons --header --time-style=long-iso -l -h -a";
      };
    };
  };
}
