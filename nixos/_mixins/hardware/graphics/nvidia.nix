{ pkgs, config, lib, inputs, ... }:
let
  displaySetupScript = pkgs.writeShellScript "display_setup.sh" ''
    #!/bin/sh
    ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource NVIDIA-G0 modesetting
    ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal
  '';

  nvStable = config.boot.kernelPackages.nvidiaPackages.stable;
  nvBeta = config.boot.kernelPackages.nvidiaPackages.beta;
  nvidiaPkg =
    if (lib.versionOlder nvBeta.version nvStable.version)
    then config.boot.kernelPackages.nvidiaPackages.stable
    else config.boot.kernelPackages.nvidiaPackages.beta;
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';

  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";
in
{
  # sessionVariables.NIXOS_OZONE_WL = "1"; # Fix for electron apps with wayland
  # Wayland
  # variables = {
  #   GBM_BACKEND = "nvidia-drm";
  #   LIBVA_DRIVER_NAME = "nvidia";
  #   __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  # };
  # package = config.boot.kernelPackages.nvidiaPackages.beta;
  # package = config.boot.kernelPackages.nvidiaPackages.stable;
  # package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  # package = pkgs.linuxKernel.packages.linux_xanmod_stable.nvidia_x11_legacy470;
  # package = pkgs.linuxKernel.packages.linux_xanmod_stable.nvidia_x11_stable_open;
  # package = pkgs.linuxKernel.packages.linux_zen.nvidia_x11;
  # enable secondary monitors at boot time

  # xrandr --setprovideroffloadsink NVIDIA modesetting
  # xrandr --setprovideroffloadsink 1 0
  config = {
    # For all specialisations
    environment.systemPackages = with pkgs; [
      glxinfo
      inxi
      nvtop-nvidia
      xorg.xdpyinfo
    ];
    boot.kernelParams = [ "intel_iommu=igfx_off" ];
    specialisation = {
      nvidia-display.configuration = lib.mkDefault {
        system.nixos.tags = [ "nvidia-display" ];
        boot = {
          loader.grub.configurationName = lib.mkForce "Nvidia Power Mode";
          blacklistedKernelModules = lib.mkForce [
            "nouveau"
            "rivafb"
            "nvidiafb"
            "rivatv"
            "nv"
            "uvcvideo"
          ];
          kernelModules = [
            "clearcpuid=514" # Fixes certain wine games crash on launch
            "nvidia"
            "nvidia_modeset"
            "nvidia_uvm"
            "nvidia_drm"
          ];
          kernelParams = lib.mkDefault [
            "nouveau.modeset=0"
            "nohibernate"
            "nvidia-drm.modeset=1"
          ];
          extraModprobeConfig = ''
            options nvidia NVreg_UsePageAttributeTable=1
            options nvidia NVreg_RegistryDwords="OverrideMaxPerf=0x1"
            options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
          '';
          kernel.sysctl = lib.mkDefault { "vm.max_map_count" = 2147483642; };
        };
        hardware = {
          opengl = {
            extraPackages = with pkgs; [
              nvidia-vaapi-driver
            ];
          };
          nvidia = {
            package = nvidiaPkg;
            # package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
            #open = true;
            nvidiaSettings = lib.mkDefault true;
            # nvidiaPersistenced = true;
            prime = {
              # offload = {
              #   enable = lib.mkForce false;
              #   enableOffloadCmd = lib.mkForce false;
              inherit intelBusId;
              inherit nvidiaBusId;
              sync.enable = true;
              # reverseSync.enable = lib.mkForce false;
            };
            # };
            modesetting.enable = true;
            powerManagement = {
              enable = lib.mkForce true;
              finegrained = lib.mkForce false;
            };
            # forceFullCompositionPipeline = true;
          };

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
        environment = {
          systemPackages = with pkgs; [
            # nvidia-offload
            vulkan-loader
            nvtop-nvidia
            # vulkan-validation-layers
            # vulkan-tools
            # nvitop
          ];
          variables = {
            NVD_BACKEND = "direct";
          };
        };
        virtualisation.podman.enableNvidia = true;
      };
      nvidia-nouveau.configuration = {
        system.nixos.tags = [ "nvidia-nouveau" ];
        imports = [ inputs.nixos-hardware.nixosModules.common-gpu-nvidia ];
        boot = {
          loader.grub.configurationName = lib.mkForce "Nvidia Nouveau";
          # kernelParams = lib.mkDefault [
          #   "clearcpuid=514" # Fixes certain wine games crash on launch
          #   "nvidia"
          #   "nvidia_modeset"
          #   "nvidia-uvm"
          #   "nvidia_drm"
          #   "nvidia-drm.modeset=1"
          # ];
        };
        hardware.nvidia = {
          package = nvidiaPkg;
          #open = lib.mkForce false;
          nvidiaSettings = lib.mkDefault false;
          # prime = {
          #   inherit intelBusId;
          #   inherit nvidiaBusId;
          #   sync.enable = true;
          # };
          modesetting.enable = true;
          powerManagement = {
            enable = lib.mkDefault true;
            finegrained = lib.mkDefault false;
          };
          # forceFullCompositionPipeline = true;
        };
        virtualisation.podman.enableNvidia = true;
        environment = {
          systemPackages = with pkgs; [
            nvtop-nvidia
          ];
        };
        services.xserver.videoDrivers = [ "nouveau" ];
      };
      nvidia-offload.configuration = {
        system.nixos.tags = [ "nvidia-offload" ];
        boot = {
          loader.grub.configurationName = lib.mkForce "Nvidia Offload";
          blacklistedKernelModules = lib.mkForce [
            "nouveau"
            "rivafb"
            "nvidiafb"
            "rivatv"
            "nv"
            "uvcvideo"
          ];
          kernelModules = [
            "clearcpuid=514" # Fixes certain wine games crash on launch
            "nvidia"
            "nvidia_modeset"
            "nvidia_uvm"
            "nvidia_drm"
          ];
          kernelParams = lib.mkDefault [
            "nouveau.modeset=0"
          ];
          kernel.sysctl = lib.mkDefault { "vm.max_map_count" = 2147483642; };
        };
        hardware = {
          nvidia = {
            # package = nvidiaPkg;
            package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
            #open = true;
            prime = {
              offload = {
                enable = true;
                enableOffloadCmd = true;
              };
              inherit intelBusId;
              inherit nvidiaBusId;
              reverseSync.enable = true;
            };
            nvidiaSettings = lib.mkDefault true;
            modesetting.enable = true;
            powerManagement = {
              enable = lib.mkDefault true;
              finegrained = lib.mkDefault true;
            };
            forceFullCompositionPipeline = true;
            # nvidiaPersistenced = true;
          };
        };
        services = {
          xserver = {
            videoDrivers = [ "nvidia" ];
            # displayManager = {
            #   setupCommands = ''
            #     ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource NVIDIA-G0 modesetting
            #     ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal
            #   '';
            #   # ${pkgs.xorg.xrandr}/bin/xrandr --auto
            # };
          };
        };
        environment = {
          systemPackages = with pkgs; [
            # displaySetupScript
            nvidia-offload
            vulkan-loader
            vulkan-validation-layers
            vulkan-tools
            nvtop-nvidia
            arandr
          ];
        };
        virtualisation.podman.enableNvidia = true;
      };
    };
  };
}
