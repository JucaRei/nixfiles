{
  config,
  lib,
  pkgs ? pkgs.oldstable,
  ...
}:
let
  inherit (lib) mkDefault mkIf mkForce;
  device = config.hardware.graphics.cards;
in
{
  config = mkIf (device.gpu == "nvidia-legacy") {
    boot = {
      blacklistedKernelModules = [
        "nouveau"
        "nvidiafb"
      ];
      extraModulePackages = [
        config.boot.kernelPackages.nvidia_x11_legacy340
      ];
      kernelModules = [
        "nvidia"
      ];
    };

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          libva-vdpau-driver
          libvdpau-va-gl
        ];
        extraPackages32 = with pkgs.pkgsi686Linux; [
          libva-vdpau-driver
          libvdpau-va-gl
        ];
      };
    };

    services = {
      acpid = {
        enable = true;
      };
      xserver = {
        deviceSection = lib.mkDefault ''
          Option "TearFree" "true"
        '';
        serverFlagsSection = ''
          Option "IgnoreABI" "true"
        '';
        screenSection = ''
          Option     "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
        '';
        # Driver carregado via boot.extraModulePackages; xserver usa o driver instalado pelo módulo do kernel
        videoDrivers = lib.mkForce [ ];
      };
    };

    environment = {
      sessionVariables = mkDefault {
        LIBVA_DRIVER_NAME = mkForce "vdpau";
        VDPAU_DRIVER = mkForce "nvidia";
        # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        # GBM_BACKEND = "nvidia-drm";
        # WLR_NO_HARDWARE_CURSORS = "1";
      };
      systemPackages = with pkgs; [
        mesa-demos
        libva-utils
        vdpauinfo
        pkgsi686Linux.vdpauinfo
      ];

      # variables = {
      # VAAPI_MPEG4_ENABLED= true;
      # };

      # 'nvidia_x11' installs it's files to /run/opengl-driver/...
      # etc = {
      # "egl/egl_external_platform.d".source = "/run/opengl-driver/share/egl/egl_external_platform.d/";
      # "egl/egl_external_platform.d".source = "/run/opengl-driver/share/egl/egl_external_platform.d/";
      # };
    };
  };
}
