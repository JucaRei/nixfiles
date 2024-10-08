{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    ./amd
    ./intel
    ./nvidia
    ./nvidia-legacy
  ];

  options.features.graphics = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable graphics for selected device.";
    };
    gpu = mkOption {
      type = types.enum [ "amd" "intel" "nvidia" "nvidia-legacy" "hybrid-nvidia" "hybrid-amd" "integrated-amd" "pi" "mali-gpu" null ];
      default = null;
      description = "Manufacturer/type of the primary system GPU";
    };
  };
}
