{ config, hostname, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  hasCUDA = lib.elem "cudaPackages.cudatoolkit" config.environment.systemPackages;
  hasOpenCL = config.hardware.amdgpu.opencl.enable;
  cfg = config.desktop.apps.blender;
in
{
  options = {
    desktop.apps.blender = {
      enable = mkEnableOption "Install blender.";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (blender.override {
        cudaSupport = hasCUDA;
        hipSupport = hasOpenCL;
      })
    ];
  };
}
