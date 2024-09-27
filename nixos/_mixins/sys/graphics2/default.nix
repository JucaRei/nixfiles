{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption types mkEnableOption;
in
{
  imports = [
    ./amd
    ./intel
    ./nvidia
  ];

  options.core.graphics = {
    enable = mkEnableOption "Enable graphics for your device.";
    gpu = mkOption {
      type = types.enum [ "amd" "intel" "nvidia" "hybrid-nvidia" "hybrid-amd" "integrated-amd" "pi" null ];
      default = null;
      description = "Manufacturer/type of the primary system GPU";
    };
  };
}
