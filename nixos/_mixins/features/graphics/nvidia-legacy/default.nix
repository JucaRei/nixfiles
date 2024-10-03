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
    };

    services = {
      xserver = {
        # deviceSection = lib.mkDefault ''
        #   Option "TearFree" "true"
        # '';
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
        # screenSection = ''
        #   Option     "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
        # '';
        videoDrivers = [ "nvidia" ];
      };
    };

    environment = {
      # sessionVariables = {
      #   LIBVA_DRIVER_NAME = "nvidia";
      # };
      systemPackages = with pkgs; [
        glxinfo
        mame
        libva
        libva-utils
      ];
    };
  };
}
