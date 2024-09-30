{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
  device = config.features.graphics;

  
in
{
  config = mkIf (device.gpu == "intel" || device.gpu == "hybrid-nv") {

    boot = {
      initrd.kernelModules = [ "i915" ];
      kernelParams = [
        "enable_gvt=1"
        "i915.fastboot=1"
      ];
      kernelModules = [ "kvm-intel" ];
    };
    services.xserver.videoDrivers = [ "modesetting" ];

    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };

    hardware.opengl = {
      extraPackages = with pkgs; [
        intel-compute-runtime
        intel-media-driver
        libvdpau-va-gl
        vaapiIntel
        vaapiVdpau
      ];
    };

    environment.variables = mkIf (config.hardware.opengl.enable && device.gpu != "hybrid-nv") {
      VDPAU_DRIVER = "va_gl";
    };
  };
}
