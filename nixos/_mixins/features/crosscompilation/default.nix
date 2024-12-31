{ config, lib, ... }:
let
  inherit (lib) mkOption types mkIf;
  cfg = config.features.crosscompilation;
in
{
  options = {
    features.crosscompilation = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables cross compilation of nix builds";
      };
      platform = mkOption {
        type = types.str;
        default = "aarch64-linux";
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
