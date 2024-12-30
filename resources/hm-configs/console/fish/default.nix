{ lib, config, ... }:
let
  inherit (lib) mkOption types mkIf;
  cfg = config.console.fish;
in
{
  imports = [
    # ../starship.nix
  ];

  options.console.fish = {
    enable = mkOption {
      default = false;
      type = types.bool;
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
        builtins.readFile ../../../dots/fish/help.fish;
      "${config.xdg.configHome}/fish/functions/h.fish".text =
        builtins.readFile ../../../dots/fish/h.fish;
      "${config.xdg.configHome}/fish/functions/lima-create.fish".text =
        builtins.readFile ../../../dots/fish/lima-create.fish;
      "${config.xdg.configHome}/fish/functions/gpg-restore.fish".text =
        builtins.readFile ../../../dots/fish/gpg-restore.fish;
      "${config.xdg.configHome}/fish/functions/get-nix-hash.fish".text =
        builtins.readFile ../../../dots/fish/get-nix-hash.fish;
    };
  };
}
