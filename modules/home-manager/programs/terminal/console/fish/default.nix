{ lib, config, ... }:
let
  inherit (lib) mkOption types mkIf;
  cfg = config.programs.terminal.console.fish;
in
{

  options = {
    programs.terminal.console.fish = {
      enable = mkOption {
        default = false;
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    programs = {
      fish = {
        enable = true;
      };
    };

    home.file = {
      "${config.xdg.configHome}/fish/functions/help.fish".text =
        builtins.readFile ./confs/help.fish;
      "${config.xdg.configHome}/fish/functions/h.fish".text =
        builtins.readFile ./confs/h.fish;
      "${config.xdg.configHome}/fish/functions/lima-create.fish".text =
        builtins.readFile ./confs/lima-create.fish;
      "${config.xdg.configHome}/fish/functions/gpg-restore.fish".text =
        builtins.readFile ./confs/gpg-restore.fish;
      "${config.xdg.configHome}/fish/functions/get-nix-hash.fish".text =
        builtins.readFile ./confs/get-nix-hash.fish;
    };
  };
}
