{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge versionAtLeast;
  device = config.features.graphics;
  backend = config.features.backend;
  graphics = config.features.graphics.enable;
in
{
  config = mkIf (device.gpu == "amd" || device.gpu == "hybrid-amd" || device.gpu == "integrated-amd") {
    boot = mkMerge [
      (mkIf (versionAtLeast pkgs.linux.version "6.2") {
        kernelModules = [
          "amdgpu"
        ];
        #   kernelParams = mkIf (device.gpu == "integrated-amd")
        #     [
        #       "amdgpu.sg_display=0"
        #     ];
      })
    ];

    services.xserver.videoDrivers = (mkIf graphics && (backend == "x")) [
      "amdgpu"
    ];

    hardware = {
      graphics = {
        extraPackages = with pkgs; [
          amdvlk
          rocmPackages.clr
          rocmPackages.clr.icd
        ];
      };
    };

    environment = {
      sessionVariables = mkMerge [
        (mkIf graphics {
          LIBVA_DRIVER_NAME = "radeonsi";
        })
      ];
    };
  };
}
