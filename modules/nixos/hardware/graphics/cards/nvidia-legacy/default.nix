{
  config,
  lib,
  pkgs,
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
      kernelModules = [
        "nvidia"
      ];
      extraModprobeConfig = ''
        options nvidia NVreg_UsePageAttributeTable=1 NVreg_RegistryDwords="EnableBrightnessControl=1"
      '';
    };

    hardware = {
      nvidia = {
        package = config.boot.kernelPackages.nvidia_x11_legacy340;
        nvidiaSettings = true;
      };

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
        videoDrivers = [ "nvidia" ];
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
      sessionVariables = mkDefault {
        LIBVA_DRIVER_NAME = mkForce "vdpau";
        VDPAU_DRIVER = mkForce "nvidia";
      };
      systemPackages = with pkgs; [
        mesa-demos
        libva-utils
        vdpauinfo
        pkgsi686Linux.vdpauinfo
      ];
    };
  };
}
