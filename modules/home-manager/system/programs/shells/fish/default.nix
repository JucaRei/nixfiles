{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
  cfg = config.system.programs.shell;
in
{
  config = mkIf (cfg.default == "fish") {
    programs.fish = {
      enable = true;
    };
  };
}
