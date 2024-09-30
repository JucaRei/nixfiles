{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
  device = config.features.graphics;
in
{
  config = mkIf (device.gpu == "amd" || device.gpu == "hybrid-amd" || device.gpu == "integrated-amd") {
    boot = lib.mkMerge [
      (lib.mkIf (lib.versionAtLeast pkgs.linux.version "6.2") {
        kernelModules = [
          "amdgpu"
        ];
        kernelParams = mkIf (device.gpu == "integrated-amd")
          [
            "amdgpu.sg_display=0"
          ];
      })
    ];

    ## 24.11 Change to hardware.graphics.extraPackages
    #hardware.opengl.extraPackages = with pkgs; [
    # hardware.graphics.extraPackages = with pkgs; [
    #   amdvlk
    #   rocmPackages.clr
    #   rocmPackages.clr.icd
    # ];

    services.xserver.videoDrivers = [
      "amdgpu"
    ];
  };
}
