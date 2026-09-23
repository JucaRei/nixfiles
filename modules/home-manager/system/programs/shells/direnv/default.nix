{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.system.programs.shells;
in
{
  config = mkIf (cfg.enable && cfg.direnv.enable) {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = cfg.direnv.nix-direnv;
      enableBashIntegration = mkIf (cfg.default == "bash") true;
      enableFishIntegration = mkIf (cfg.default == "fish") true;
      enableZshIntegration = mkIf (cfg.default == "zsh") true;
      enableNushellIntegration = mkIf (cfg.default == "nu") true;

      stdlib = mkIf cfg.direnv.nix-direnv ''
        : ''${DIRENV_AUTO_LOAD_FLAKE:=1}
        if [ -f flake.nix ] && [ ! -f .envrc ] && (( DIRENV_AUTO_LOAD_FLAKE )); then
          echo "use flake" > .envrc
          direnv allow
        fi
      '';
    };
  };
}
