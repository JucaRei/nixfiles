{ config, lib, pkgs, hostname, ... }:
let
  inherit (lib) mkIf;
  device = config.features.graphics;
in
{
  # config = mkIf (device.gpu == "intel" || device.gpu == "hybrid-nv") {
  config = mkIf (device.gpu == "intel" || device.gpu == "hybrid-nvidia") {

    boot = {
      initrd.kernelModules = mkIf (device.gpu == "intel") [ "i915" ];
      kernelParams = mkIf (device.gpu == "intel") [
        "enable_gvt=1"
        "i915.fastboot=1"
      ];
      kernelModules = [ "kvm-intel" ];
    };
    services.xserver.videoDrivers =
      if (device.gpu == "hybrid-nvidia") then [ "modesetting" ]
      else if (hostname == "anubis") then [
        "i965"
      ]
      else [ "intel" ];

    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };

    hardware.graphics = (mkIf (device.gpu == "hybrid-nvidia") {
      enable = true;
      enable32Bit = true;
      extraPackages = (with pkgs.unstable; [
        # intel-compute-runtime
        # intel-media-driver
        # libvdpau-va-gl
        vaapiIntel
        mesa
      ]);
    });

    environment = {
      variables = mkIf (config.hardware.graphics.enable && device.gpu != "hybrid-nvidia") {
        VDPAU_DRIVER = "va_gl";
      };
      systemPackages = (mkIf (device.gpu == "intel") (with pkgs.unstable; [
        intel-compute-runtime
        intel-media-driver
        libvdpau-va-gl
        vaapiIntel
        # vaapiVdpau
      ]));
    };
  };
}
