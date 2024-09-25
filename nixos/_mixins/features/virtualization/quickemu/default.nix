{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.features.virtualisation.quickemu;
in
{
  options.features.virtualisation.quickemu = {
    enable = mkEnableOption "Enables quickemu";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [ unstable.quickemu ];
  };
}
