{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
  cfg = config.system.programs.shells;
in
{
  config = mkIf (cfg.default == "fish") {
    programs.fish = {
      enable = true;
    };
  };
}
