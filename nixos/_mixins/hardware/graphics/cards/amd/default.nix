{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge versionAtLeast;
  device = config.hardware.cards;
  backend = config.programs.graphical.desktop.backend;
  graphics = config.hardware.cards.enable;
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

    services.xserver.videoDrivers = (mkIf graphics && (backend == "x11")) [
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
