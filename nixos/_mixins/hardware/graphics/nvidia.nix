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
    export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json"
    export LIBVA_DRIVER_NAME="nvidia"
    exec "$@"
  '';

  kernelModules = [

  ];
  blacklisted = [

  ];

  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";

  # ### With nvidia
  # inherit (pkgs) libva;
  # inherit (pkgs.lib.makeOverridableArgs) override;
  # vaapiNvidia = pkgs.nvidia_x11.override {
  #   vaapiSupport = true;
  #   vdpauSupport = true;
  # };
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
    # Default config load
    boot = {
      blacklistedKernelModules = [
        "nouveau"
        "rivafb"
        "nvidiafb"
        "rivatv"
        "nv"
        "uvcvideo"
      ];
      kernelParams = lib.mkDefault [
        "nouveau.modeset=0"
      ];
      kernelModules = [
        "clearcpuid=514" # Fixes certain wine games crash on launch
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];
      extraModprobeConfig = ''
        options nvidia NVreg_UsePageAttributeTable=1
        options nvidia NVreg_RegistryDwords="OverrideMaxPerf=0x1"
        options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
      '';
    };
    hardware = {
      nvidia = {
        # package = nvidiaPkg;
        package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
        #open = true;
        prime = {
          offload = {
            enable = lib.mkForce false;
            enableOffloadCmd = lib.mkForce false;
          };
          inherit intelBusId;
          inherit nvidiaBusId;
          reverseSync.enable = true;
        };
        nvidiaSettings = lib.mkDefault true;
        modesetting.enable = true;
        powerManagement = {
          enable = lib.mkDefault false;
          finegrained = lib.mkDefault false;
        };
        forceFullCompositionPipeline = true;
        nvidiaPersistenced = true;
      };
    };
    services = {
      xserver = {
        videoDrivers = [ "nvidia" ];
        displayManager = {
          # setupCommands = ''
          #   ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource NVIDIA-G0 modesetting
          #   ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal
          # '';
          # ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal
          #   # ${pkgs.xorg.xrandr}/bin/xrandr --auto
          # sessionCommands = ''
          #   ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource modesetting NVIDIA-G0
          #   ${pkgs.xorg.xrandr}/bin/xrandr --auto
          # '';
          # ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal
        };
      };
    };
    environment = {
      systemPackages = with pkgs; [
        # displaySetupScript
        # nvidia-offload
        vulkan-loader
        vulkan-validation-layers
        vulkan-tools
        glxinfo
        inxi
        nvtop-nvidia
        xorg.xdpyinfo
        # nvtop-nvidia
        # arandr
      ];
      variables = lib.mkDefault {
        "VK_ICD_FILENAMES" = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/intel_icd.i686.json";
        GBM_BACKEND = "nvidia-drm";
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        NVD_BACKEND = "direct";
      };
    };

    specialisation = {
      nvidia-opengl.configuration = lib.mkForce {
        system.nixos.tags = [ "nvidia-opengl" ];
        boot = {
          loader.grub.configurationName = lib.mkForce "Nvidia Opengl";
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
            # "nvidia-drm.modeset=1"
          ];
          extraModprobeConfig = ''
            options nvidia NVreg_UsePageAttributeTable=1
            options nvidia NVreg_RegistryDwords="OverrideMaxPerf=0x1"
            options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
          '';
          kernel.sysctl = lib.mkDefault { "vm.max_map_count" = 2147483642; };
        };
        hardware = {
          nvidia = {
            # package = nvidiaPkg;
            package = config.boot.kernelPackages.nvidiaPackages.beta;
            modesetting = {
              enable = true;
            };
            nvidiaPersistenced = true;
            powerManagement.enable = true;
            nvidiaSettings = true;
          };
        };
        environment = {
          variables = lib.mkDefault {
            GBM_BACKEND = "nvidia-drm";
            LIBVA_DRIVER_NAME = "nvidia";
            __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          };
          systemPackages = with pkgs; [
            clinfo
            virtualglLib
            vulkan-loader
            vulkan-tools
          ];
        };
        services.xserver = {
          videoDrivers = [ "nvidia" ];
          screenSection = ''
            Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
            Option         "AllowIndirectGLXProtocol" "off"
            Option         "TripleBuffer" "on"
          '';
        };
      };
      nvidia-vulkan.configuration = lib.mkForce {
        system.nixos.tags = [ "nvidia-vulkan" ];
        boot = {
          loader.grub.configurationName = lib.mkForce "Nvidia Vulkan";
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
            # "nvidia-drm.modeset=1"
          ];
          extraModprobeConfig = ''
            options nvidia NVreg_UsePageAttributeTable=1
            options nvidia NVreg_RegistryDwords="OverrideMaxPerf=0x1"
            options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
          '';
          kernel.sysctl = lib.mkDefault { "vm.max_map_count" = 2147483642; };
        };
        hardware = {
          nvidia = {
            # package = nvidiaPkg;
            package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
            modesetting = {
              enable = true;
            };
            nvidiaPersistenced = true;
            powerManagement.enable = true;
            nvidiaSettings = true;
            forceFullCompositionPipeline = true;
          };
        };
        environment = {
          variables = lib.mkDefault {
            GBM_BACKEND = "nvidia-drm";
            LIBVA_DRIVER_NAME = "nvidia";
            __GLX_VENDOR_LIBRARY_NAME = "nvidia";
            NVD_BACKEND = "direct";
          };
          systemPackages = with pkgs; [
            nvidia-vaapi-driver
            clinfo
            virtualglLib
            vulkan-loader
            vulkan-tools
          ];
        };
        services.xserver = {
          videoDrivers = [ "nvidia" ];
          screenSection = ''
            Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
            Option         "AllowIndirectGLXProtocol" "off"
            Option         "TripleBuffer" "on"
          '';
        };
      };
      nvidia-disabled.configuration = lib.mkForce {
        boot = {
          loader.grub.configurationName = lib.mkForce "Nvidia Disabled";
          extraModprobeConfig = ''
            blacklist nouveau
            options nouveau modeset=0
          '';
        };
        services.udev.extraRules = ''
          # Remove NVIDIA USB xHCI Host Controller devices, if present
          ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

          # Remove NVIDIA USB Type-C UCSI devices, if present
          ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

          # Remove NVIDIA Audio devices, if present
          ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

          # Remove NVIDIA VGA/3D controller devices
          ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
        '';
        boot.blacklistedKernelModules = [

          "nouveau"
          "nvidia"
          "nvidia_drm"
          "nvidia_modeset"

        ];
      };
      # nvidia-display.configuration = lib.mkDefault {
      #   system.nixos.tags = [ "nvidia-display" ];
      #   boot = {
      #     loader.grub.configurationName = lib.mkForce "Nvidia Power Mode";
      #     blacklistedKernelModules = lib.mkForce [
      #       "nouveau"
      #       "rivafb"
      #       "nvidiafb"
      #       "rivatv"
      #       "nv"
      #       "uvcvideo"
      #     ];
      #     kernelModules = [
      #       "clearcpuid=514" # Fixes certain wine games crash on launch
      #       "nvidia"
      #       "nvidia_modeset"
      #       "nvidia_uvm"
      #       "nvidia_drm"
      #     ];
      #     kernelParams = lib.mkDefault [
      #       "nouveau.modeset=0"
      #       "nohibernate"
      #       "nvidia-drm.modeset=1"
      #     ];
      #     extraModprobeConfig = ''
      #       options nvidia NVreg_UsePageAttributeTable=1
      #       options nvidia NVreg_RegistryDwords="OverrideMaxPerf=0x1"
      #       options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
      #     '';
      #     kernel.sysctl = lib.mkDefault { "vm.max_map_count" = 2147483642; };
      #   };
      #   hardware = {
      #     opengl = {
      #       extraPackages = with pkgs; [
      #         nvidia-vaapi-driver
      #         # vaapiNvidia
      #       ];
      #     };
      #     nvidia = {
      #       package = nvidiaPkg;
      #       # package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
      #       #open = true;
      #       nvidiaSettings = lib.mkDefault true;
      #       # nvidiaPersistenced = true;
      #       prime = {
      #         #   # offload = {
      #         #   #   enable = lib.mkForce false;
      #         #   #   enableOffloadCmd = lib.mkForce false;
      #         inherit intelBusId;
      #         inherit nvidiaBusId;
      #         sync.enable = true;
      #         #   # reverseSync.enable = lib.mkForce false;
      #       };
      #       # };
      #       modesetting.enable = true;
      #       # powerManagement = {
      #       #   enable = lib.mkForce true;
      #       #   finegrained = lib.mkForce false;
      #       # };
      #       # forceFullCompositionPipeline = true;
      #     };

      #   };
      #   services = {
      #     xserver = {
      #       videoDrivers = [ "nvidia" ];
      #       screenSection = ''
      #         Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      #         Option         "AllowIndirectGLXProtocol" "off"
      #         Option         "TripleBuffer" "on"
      #       '';
      #     };
      #   };
      #   environment = {
      #     systemPackages = with pkgs; [
      #       # nvidia-offload
      #       vulkan-loader
      #       # nvtop-nvidia
      #       # vulkan-validation-layers
      #       # vulkan-tools
      #       # nvitop
      #     ];
      #     variables = {
      #       NVD_BACKEND = "direct";
      #     };
      #   };
      #   virtualisation.podman.enableNvidia = true;
      # };
      # nvidia-nouveau.configuration = {
      #   system.nixos.tags = [ "nvidia-nouveau" ];
      #   imports = [ inputs.nixos-hardware.nixosModules.common-gpu-nvidia ];
      #   boot = {
      #     loader.grub.configurationName = lib.mkForce "Nvidia Nouveau";
      #     # kernelParams = lib.mkDefault [
      #     #   "clearcpuid=514" # Fixes certain wine games crash on launch
      #     #   "nvidia"
      #     #   "nvidia_modeset"
      #     #   "nvidia-uvm"
      #     #   "nvidia_drm"
      #     #   "nvidia-drm.modeset=1"
      #     # ];
      #   };
      #   hardware.nvidia = {
      #     package = nvidiaPkg;
      #     #open = lib.mkForce false;
      #     nvidiaSettings = lib.mkDefault false;
      #     # prime = {
      #     #   inherit intelBusId;
      #     #   inherit nvidiaBusId;
      #     #   sync.enable = true;
      #     # };
      #     modesetting.enable = true;
      #     powerManagement = {
      #       enable = lib.mkDefault true;
      #       finegrained = lib.mkDefault false;
      #     };
      #     # forceFullCompositionPipeline = true;
      #   };
      #   virtualisation.podman.enableNvidia = true;
      #   environment = {
      #     systemPackages = with pkgs; [
      #       nvtop-nvidia
      #     ];
      #   };
      #   services.xserver.videoDrivers = [ "nouveau" ];
      # };
      # nvidia-Reverse.configuration = {
      #   system.nixos.tags = [ "nvidia-Reverse" ];
      #   boot = {
      #     loader.grub.configurationName = lib.mkForce "Reverse sync";
      #     # blacklistedKernelModules = lib.mkForce [
      #     # "nouveau"
      #     # "rivafb"
      #     # "nvidiafb"
      #     # "rivatv"
      #     # "nv"
      #     # "uvcvideo"
      #     # ];
      #     # kernelModules = [
      #     # "clearcpuid=514" # Fixes certain wine games crash on launch
      #     # "nvidia"
      #     # "nvidia_modeset"
      #     # "nvidia_uvm"
      #     # "nvidia_drm"
      #     # ];
      #     # kernelParams = lib.mkDefault [
      #     # "nouveau.modeset=0"
      #     # ];
      #     kernel.sysctl = lib.mkDefault { "vm.max_map_count" = 2147483642; };
      #   };
      #   hardware = {
      #     nvidia = {
      #       # package = nvidiaPkg;
      #       package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
      #       #open = true;
      #       prime = {
      #         offload = {
      #           enable = lib.mkForce false;
      #           enableOffloadCmd = lib.mkForce false;
      #         };
      #         inherit intelBusId;
      #         inherit nvidiaBusId;
      #         reverseSync.enable = true;
      #       };
      #       nvidiaSettings = lib.mkDefault true;
      #       modesetting.enable = true;
      #       powerManagement = {
      #         enable = lib.mkDefault false;
      #         finegrained = lib.mkDefault false;
      #       };
      #       # forceFullCompositionPipeline = true;
      #       # nvidiaPersistenced = true;
      #     };
      #   };
      #   services = {
      #     xserver = {
      #       videoDrivers = [ "nvidia" ];
      #       displayManager = {
      #         # setupCommands = ''
      #         #   ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource NVIDIA-G0 modesetting
      #         #   ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal
      #         # '';
      #         # ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal
      #         #   # ${pkgs.xorg.xrandr}/bin/xrandr --auto
      #         # sessionCommands = ''
      #         #   ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource modesetting NVIDIA-G0
      #         #   ${pkgs.xorg.xrandr}/bin/xrandr --auto
      #         # '';
      #         # ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal
      #       };
      #     };
      #   };
      #   environment = {
      #     systemPackages = with pkgs; [
      #       # displaySetupScript
      #       # nvidia-offload
      #       vulkan-loader
      #       vulkan-validation-layers
      #       vulkan-tools
      #       # nvtop-nvidia
      #       # arandr
      #     ];
      #     variables = {
      #       "VK_ICD_FILENAMES" = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/intel_icd.i686.json";
      #     };
      #   };
      #   virtualisation.podman.enableNvidia = true;
      # };
    };
  };
}
