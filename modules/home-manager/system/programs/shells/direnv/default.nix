{ config, lib, ... }:
let
  cfg = config.system.programs.shells;
  inherit (lib) mkIf;
in
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = mkIf (cfg.default == "bash") true;
    enableFishIntegration = mkIf (cfg.default == "fish") true;
    enableZshIntegration = mkIf (cfg.default == "zsh") true;
    enableNushellIntegration = mkIf (cfg.default == "nu") true;
  };
}
