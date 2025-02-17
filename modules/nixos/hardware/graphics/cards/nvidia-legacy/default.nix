{ config, lib, pkgs, namespace, ... }:
let
  inherit (lib) mkDefault mkIf mkForce;
  device = config.${namespace}.hardware.graphics;
in
{
  config = mkIf (device.gpu == "nvidia-legacy") {
    nixpkgs.config = {
      allowUnfree = true;
      allowBroken = true;
      nvidia.acceptLicense = true;
    };

    boot = {
      blacklistedKernelModules = [
        "nouveau"
        "nvidiafb"
      ];
      kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
        "i2c-nvidia_gpu"
      ];
    };

    hardware = {
      nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.legacy_340;
        nvidiaSettings = true;
        modesetting.enable = true;
        powerManagement.finegrained = false;
        # forceFullCompositionPipeline = true;
      };
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          vaapiVdpau
          libvdpau-va-gl
        ];
        extraPackages32 = with pkgs.driversi686Linux // pkgs.pkgsi686Linux; [
          vaapiVdpau
          libvdpau-va-gl
        ];
      };
    };

    services = {
      acpid.enable = true;
      xserver = {
        deviceSection = lib.mkDefault ''
          Option "TearFree" "true"
        '';
        # config = ''
        #   Section "Device"
        #     Identifier "Nvidia Card"
        #     Driver "nvidia"
        #     VendorName "NVIDIA Corporation"
        #     Option "RegistryDwords" "EnableBrightnessControl=1"
        #   EndSection
        # '';
        serverFlagsSection = ''
          # Option "IgnoreABI" "1"
          Option "IgnoreABI" "true"
        '';
        screenSection = ''
          # Option     "AllowIndirectGLXProtocol" "off"
          # Option     "TripleBuffer" "on"
          Option     "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
        '';
        videoDrivers = [ "nvidia" ];
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
        glxinfo
        libva-utils
        vdpauinfo
        driversi686Linux.vdpauinfo
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
