{ pkgs, lib, config, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkOption types mkIf;
  cfg = config.custom.console.fish;
in
{
  imports = [
    # ../starship.nix
  ];

  options.custom.console.fish = {
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
      # "${config.xdg.configHome}/fish/functions/build-home.fish".text =
      # builtins.readFile ../../config/fish/build-home.fish;
      # "${config.xdg.configHome}/fish/functions/switch-home.fish".text =
      # builtins.readFile ../../config/fish/switch-home.fish;
      "${config.xdg.configHome}/fish/functions/help.fish".text =
        builtins.readFile ../../../../resources/dots/fish/help.fish;
      "${config.xdg.configHome}/fish/functions/h.fish".text =
        builtins.readFile ../../../../resources/dots/fish/h.fish;
      "${config.xdg.configHome}/fish/functions/lima-create.fish".text =
        builtins.readFile ../../../../resources/dots/fish/lima-create.fish;
      "${config.xdg.configHome}/fish/functions/gpg-restore.fish".text =
        builtins.readFile ../../../../resources/dots/fish/gpg-restore.fish;
      "${config.xdg.configHome}/fish/functions/get-nix-hash.fish".text =
        builtins.readFile ../../../../resources/dots/fish/get-nix-hash.fish;
    };
  };
}
