{ config, lib, pkgs, ... }:
let
  inherit (lib) mkDefault mkIf;
  device = config.features.graphics;
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
      ];
    };

    hardware = {
      nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.legacy_340;
        nvidiaSettings = true;
        # modesetting.enable = false;
        # forceFullCompositionPipeline = true;
      };
      opengl = {
        enable = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
        ];
      };
    };

    services = {
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
          Option     "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
        '';
        videoDrivers = [ "nvidia" ];
      };
    };

    environment = {
      sessionVariables = {
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        # GBM_BACKEND = "nvidia-drm";
        WLR_NO_HARDWARE_CURSORS = "1";
      };
      systemPackages = with pkgs; [
        glxinfo
        libva
        libva-utils
      ];
    };
  };
}
