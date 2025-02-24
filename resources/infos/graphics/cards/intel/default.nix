{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
  device = config.features.graphics;
in
{
  # config = mkIf (device.gpu == "intel" || device.gpu == "hybrid-nv") {
  config = mkIf (device.gpu == "intel" || device.gpu == "hybrid-nvidia") {

    boot = {
      initrd.kernelModules = [ "i915" ];
      kernelParams = [
        "enable_gvt=1"
        "i915.fastboot=1"
      ];
      kernelModules = [ "kvm-intel" ];
    };
    #servicesxserver.videoDrivers = [ "modesetting" ];

    # if (device.gpu == "hybrid-nvidia") then
    #   [ "modesetting" ]
    # else if (hostname == "anubis") then [
    #   "i965"
    # ]
    # else [ "intel" ];
    # else [ "i965" ];



    # hardware.graphics = (mkIf (device.gpu == "hybrid-nvidia") {
    #   enable = true;
    #   enable32Bit = true;
    #   extraPackages = (with pkgs.unstable; [
    #     #intel-compute-runtime
    #     #intel-media-driver
    #     #libvdpau-va-gl
    #     #vpl-gpu-rt # for newer GPUs on NixOS >24.05 or unstable
    #     #onevpl-intel-gpu  # for newer GPUs on NixOS <= 24.05
    #     #intel-media-sdk   # for older GPUs
    #     vaapiIntel
    #     vaapiVdpau
    #   ]);
    # });

    environment = {
      variables = mkIf (config.hardware.graphics.enable && device.gpu != "hybrid-nvidia") {
        VDPAU_DRIVER = "va_gl";
      };
      # systemPackages = (mkIf (device.gpu == "intel") (with pkgs.unstable; [
      #   intel-compute-runtime
      #   intel-media-driver
      #   libvdpau-va-gl
      #   vaapiIntel
      # ]));
    };
  };
}
