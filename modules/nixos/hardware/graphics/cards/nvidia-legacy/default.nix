{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkForce;
  device = config.hardware.graphics.cards;
  legacy340 = config.boot.kernelPackages.nvidia_x11_legacy340;
in
{
  config = mkIf (device.gpu == "nvidia-legacy") {
    boot = {
      blacklistedKernelModules = [
        "nouveau"
        "nvidiafb"
      ];
      extraModulePackages = [
        legacy340.bin
        legacy340.mod
      ];
      kernelModules = [
        "nvidia"
      ];
      extraModprobeConfig = ''
        options nvidia NVreg_UsePageAttributeTable=1 NVreg_RegistryDwords="EnableBrightnessControl=1"
      '';
    };

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          legacy340.bin
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
        videoDrivers = mkForce [ ];
        drivers = [
          {
            name = "nvidia";
            modules = [ legacy340.bin ];
            display = true;
          }
        ];
        deviceSection = ''
          Option "RegistryDwords" "EnableBrightnessControl=1"
        '';
        serverFlagsSection = ''
          Option "IgnoreABI" "true"
        '';
        screenSection = ''
          Option "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
        '';
      };
    };

    environment = {
      sessionVariables = {
        LIBVA_DRIVER_NAME = "vdpau";
        VDPAU_DRIVER = "nvidia";
      };
      systemPackages = with pkgs; [
        legacy340.settings
        mesa-demos
        libva-utils
        vdpauinfo
        pkgsi686Linux.vdpauinfo
      ];
    };
  };
}
