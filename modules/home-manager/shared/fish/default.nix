{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.fish;
in
{
  options.modules.fish = {
    enable = mkOption {
      default = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs = {
      fish = {
        enable = true;
        catppuccin.enable = true;
      };
    };

    home.file = {
      "${config.xdg.configHome}/fish/functions/help.fish".text = builtins.readFile ../../../../resources/configs/fish/help.fish;
      "${config.xdg.configHome}/fish/functions/h.fish".text = builtins.readFile ../../../../resources/configs/fish/h.fish;
      ".hidden".text = ''snap'';
    };
  };
}
