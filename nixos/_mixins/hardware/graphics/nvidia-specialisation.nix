{ pkgs, config, lib, inputs, ... }:
let
  # Nvidia Packages
  production = config.boot.kernelPackages.nvidiaPackages.production;
  vulkan = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;

  # Offload
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json"
    export LIBVA_DRIVER_NAME="nvidia"
    exec "$@"
  '';

  # Configs
  modules = [
    "clearcpuid=514" # Fixes certain wine games crash on launch
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];
  blacklisted = [
    "nouveau"
    "rivafb"
    "nvidiafb"
    "rivatv"
    "nv"
    "uvcvideo"
  ];
  extraModprobe = ''
    options nvidia NVreg_UsePageAttributeTable=1
    options nvidia NVreg_RegistryDwords="OverrideMaxPerf=0x1"
    options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
  '';
  systemctl = {
    "vm.max_map_count" = 2147483642;
  };

  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";
in
{
  config = {
    specialisation = {
      nvidia-opengl.configuration = {
        system.nixos.tags = [ "Nvidia OpenGL" ];
        boot = {
          loader.grub.configurationName = "Nvidia OpenGL";
          blacklistedKernelModules = [ "${blacklisted}" ];
          kernelModules = [ "${modules}" ];
          kernelParams = [
            "nouveau.modeset=0"
            "nohibernate"
            "nvidia-drm.modeset=1"
          ];
          extraModprobeConfig = "${extraModprobe}";
          kernel.sysctl = "${systemctl}";
        };
        hardware = {
          nvidia = {
            package = production;
            modesetting.enable = true;
            prime = {
              inherit intelBusId;
              inherit nvidiaBusId;
              reverseSync.enable = true;
              allowExternalGpu = false;
            };
            nvidiaPersistenced = true;
            powerManagement = {
              enable = false;
              finegrained = false;
            };
            nvidiaSettings = true;
          };
        };
        environment = {
          variables = {
            GBM_BACKEND = "nvidia-drm";
            LIBVA_DRIVER_NAME = "nvidia";
            __GLX_VENDOR_LIBRARY_NAME = "nvidia";
            NVD_BACKEND = "direct";
          };
          systemPackages = with pkgs; [
            clinfo
            virtualglLib
            vulkan-loader
            vulkan-tools
          ];
        };
        services = {
          xserver = {
            videoDrivers = [ "nvidia" ];
            screenSection = ''
              Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
              Option         "AllowIndirectGLXProtocol" "off"
              Option         "TripleBuffer" "on"
            '';
          };
        };
      };
    };
  };
}
