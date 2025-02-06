{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf types;
  inherit (lib.types) listOf str bool;
  cfg = config.features.crosscompilation;
in
{
  options = {
    features.crosscompilation = {
      enable = mkOption {
        default = false;
        type = bool;
        description = "Enables cross compilation of nix builds";
      };
      platform = mkOption {
        type = listOf str;
        default = [ "aarch64-linux" ];
        description = "Platforms to cross compile when building";
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      binfmt = {
        emulatedSystems = [ cfg.platform ];
      };
    };
  };
}
