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
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";
in
{
  config = {
    specialisation = {
      nvidia-prime = lib.mkDefault {
        configuration = {
          system.nixos.tags = [ "nvidia-prime" ];
          boot = {
            loader.grub.configurationName = lib.mkForce "Nvidia with Prime Offload";
          };
          hardware = {
            opengl.extraPackages = with pkgs; [
              vaapiVdpau
            ];
            nvidia = {
              prime = {
                offload = {
                  enable = lib.mkOverride 990 true;
                  enableOffloadCmd = lib.mkIf config.hardware.nvidia.prime.offload.enable true; # Provides `nvidia-offload` command.
                };
                # Hardware should specify the bus ID for intel/nvidia devices
                intelBusId = "PCI:0:2:0";
                nvidiaBusId = "PCI:1:0:0";
              };
              powerManagement = {
                enable = true;
                finegrained = true;
              };
              nvidiaSettings = false;
            };
          };
          services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
        };
      };
      nvidia-disabled = {
        configuration = {
          system.nixos.tags = [ "nvidia-disabled" ];
          boot = {
            initrd.kernelModules = [ "i915" ];
            loader.grub.configurationName = lib.mkForce "Nvidia disabled, only Intel GPU";
            kernelParams = [ "i915.enable_fbc=1" "i915.enable_guc=3" ];
            extraModprobeConfig = ''
              blacklist nouveau
              options nouveau modeset=0
            '';
            blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];
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
          hardware = {
            opengl = {
              driSupport = true;
              driSupport32Bit = true;
              extraPackages = with pkgs; [
                (
                  if
                    (lib.versionOlder (lib.versions.majorMinor lib.version)
                      "23.11")
                  then vaapiIntel
                  else intel-vaapi-driver
                )
                intel-media-driver
                libvdpau
                libvdpau-va-gl
              ];
            };
          };
          environment.variables = {
            VDPAU_DRIVER =
              lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
            # LIBVA_DRIVER_NAME = lib.mkDefault "iHD";
          };
          nixpkgs.config.packageOverrides = pkgs: {
            vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
          };
          services.xserver.videoDrivers = [
            "i915"

            # Optional: Enable VA-API (Video Acceleration API) for better video playback performance
            "modesetting"
          ];
        };
      };
      nvidia-sync = {
        # inheritParentConfig = false;
        configuration = {
          system.nixos.tags = [ "nvidia-sync" ];
          boot = {
            loader.grub.configurationName = lib.mkForce "Nvidia OpenGL";
            blacklistedKernelModules = [ "nouveau" "rivafb" "nvidiafb" "rivatv" "nv" "uvcvideo" ];
            kernelModules = [
              "clearcpuid=514" # Fixes certain wine games crash on launch
              # "nvidia"
              # "nvidia_modeset"
              # "nvidia_uvm"
              # "nvidia_drm"
            ];
            kernelParams = [
              "nohibernate"
              "intel_iommu=igfx_off"
            ];
            extraModprobeConfig = ''
              options nvidia NVreg_UsePageAttributeTable=1
              options nvidia NVreg_RegistryDwords="OverrideMaxPerf=0x1"
              options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
            '';
            initrd.kernelModules = [ "i915" ];
            kernel.sysctl = { "vm.max_map_count" = 2147483642; };
          };
          hardware = {
            nvidia = {
              package = production;
              modesetting.enable = true;
              prime = {
                inherit intelBusId;
                inherit nvidiaBusId;
                # reverseSync.enable = true;
                sync.enable = true;
                # allowExternalGpu = false;
              };
              nvidiaPersistenced = true;
              powerManagement = {
                enable = true;
                finegrained = false;
              };
              nvidiaSettings = true;
            };
            opengl = {
              driSupport = true;
              driSupport32Bit = true;
              extraPackages = with pkgs; [
                (if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11") then vaapiIntel else intel-vaapi-driver)
                libvdpau-va-gl
                intel-media-driver
                nvidia-vaapi-driver
              ];
            };
          };
          environment = {
            # variables = lib.mkDefault {
            # GBM_BACKEND = "nvidia-drm";
            # LIBVA_DRIVER_NAME = "nvidia";
            # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
            # NVD_BACKEND = "direct";
            # };
            variables = {
              VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
            };
            systemPackages = with pkgs; [
              glxinfo
              vulkan-loader
            ];
          };
          services = {
            xserver = {
              videoDrivers = [ "nvidia" "i915" ];
              # screenSection = ''
              #   Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
              #   Option         "AllowIndirectGLXProtocol" "off"
              #   Option         "TripleBuffer" "on"
              # '';
            };
          };
          nixpkgs.config.packageOverrides = pkgs: {
            vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
          };
        };
      };
      # nvidia-reversesync = {
      #   # inheritParentConfig = false;
      #   configuration = {
      #     system.nixos.tags = [ "nvidia-reversesync" ];
      #     boot = {
      #       loader.grub.configurationName = lib.mkForce "Nvidia OpenGL";
      #       blacklistedKernelModules = [ "nouveau" "rivafb" "nvidiafb" "rivatv" "nv" "uvcvideo" ];
      #       kernelModules = [
      #         "clearcpuid=514" # Fixes certain wine games crash on launch
      #         # "nvidia"
      #         # "nvidia_modeset"
      #         # "nvidia_uvm"
      #         # "nvidia_drm"
      #       ];
      #       kernelParams = [
      #         "nohibernate"
      #         "intel_iommu=igfx_off"
      #       ];
      #       initrd.kernelModules = [ "i915" ];
      #       kernel.sysctl = { "vm.max_map_count" = 2147483642; };
      #     };
      #     hardware = {
      #       nvidia = {
      #         package = production;
      #         modesetting.enable = true;
      #         prime = {
      #           inherit intelBusId;
      #           inherit nvidiaBusId;
      #           reverseSync.enable = true;
      #           # sync.enable = true;
      #           # allowExternalGpu = false;
      #         };
      #         nvidiaPersistenced = true;
      #         powerManagement = {
      #           enable = true;
      #           finegrained = true;
      #         };
      #         nvidiaSettings = false;
      #       };
      #       opengl = {
      #         driSupport = true;
      #         driSupport32Bit = true;
      #         extraPackages = with pkgs; [
      #           (if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11") then vaapiIntel else intel-vaapi-driver)
      #           libvdpau-va-gl
      #           intel-media-driver
      #           nvidia-vaapi-driver
      #         ];
      #       };
      #     };
      #     environment = {
      #       # variables = lib.mkDefault {
      #       # GBM_BACKEND = "nvidia-drm";
      #       # LIBVA_DRIVER_NAME = "nvidia";
      #       # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      #       # NVD_BACKEND = "direct";
      #       # };
      #       variables = {
      #         VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
      #       };
      #       systemPackages = with pkgs; [
      #         glxinfo
      #         vulkan-loader
      #       ];
      #     };
      #     services = {
      #       xserver = {
      #         videoDrivers = [ "nvidia" "i915" ];
      #         # screenSection = ''
      #         #   Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      #         #   Option         "AllowIndirectGLXProtocol" "off"
      #         #   Option         "TripleBuffer" "on"
      #         # '';
      #       };
      #     };
      #     nixpkgs.config.packageOverrides = pkgs: {
      #       vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
      #     };
      #   };
      # };
      # nvidia-vulkansync = {
      #   configuration = {
      #     system.nixos.tags = [ "nvidia-vulkansync" ];
      #     boot = {
      #       loader.grub.configurationName = lib.mkForce "nvidia-vulkansync";
      #       blacklistedKernelModules = [ "nouveau" "rivafb" "nvidiafb" "rivatv" "nv" "uvcvideo" ];
      #       kernelModules = [
      #         "clearcpuid=514" # Fixes certain wine games crash on launch
      #       ];
      #       kernelParams = [
      #         "nohibernate"
      #         "intel_iommu=igfx_off"
      #       ];
      #       extraModprobeConfig = ''
      #         options nvidia NVreg_UsePageAttributeTable=1
      #         options nvidia NVreg_RegistryDwords="OverrideMaxPerf=0x1"
      #         options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
      #       '';
      #       kernel.sysctl = { "vm.max_map_count" = 2147483642; };
      #     };
      #     hardware = {
      #       nvidia = {
      #         package = vulkan;
      #         prime = {
      #           inherit intelBusId;
      #           inherit nvidiaBusId;
      #           sync.enable = true;
      #         };
      #         powerManagement = {
      #           enable = true;
      #           finegrained = false;
      #         };
      #         modesetting.enable = true;
      #         nvidiaPersistenced = true;
      #         forceFullCompositionPipeline = true;
      #       };
      #       opengl = {
      #         driSupport = true;
      #         driSupport32Bit = true;
      #         extraPackages = with pkgs; [
      #           (if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11") then vaapiIntel else intel-vaapi-driver)
      #           libvdpau-va-gl
      #           intel-media-driver
      #           nvidia-vaapi-driver
      #         ];
      #       };
      #     };
      #     environment = {
      #       variables = lib.mkDefault {
      #         "VK_ICD_FILENAMES" = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/intel_icd.i686.json";
      #         VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
      #         # GBM_BACKEND = "nvidia-drm";
      #         # LIBVA_DRIVER_NAME = "nvidia";
      #         # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      #         # NVD_BACKEND = "direct";
      #       };
      #       systemPackages = with pkgs; [
      #         vulkan-loader
      #         glxinfo
      #         inxi
      #       ];
      #     };
      #     services.xserver = {
      #       videoDrivers = [ "nvidia" "i915" ];
      #       # screenSection = ''
      #       #   Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      #       #   Option         "AllowIndirectGLXProtocol" "off"
      #       #   Option         "TripleBuffer" "on"
      #       # '';
      #     };
      #     nixpkgs.config.packageOverrides = pkgs: {
      #       vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
      #     };
      #   };
      # };
      nvidia-vulkanReverse = {
        configuration = {
          system.nixos.tags = [ "nvidia-vulkanReverse" ];
          boot = {
            loader.grub.configurationName = lib.mkForce "nvidia-vulkanReverse";
            blacklistedKernelModules = [ "nouveau" "rivafb" "nvidiafb" "rivatv" "nv" "uvcvideo" ];
            kernelModules = [
              "clearcpuid=514" # Fixes certain wine games crash on launch
            ];
            kernelParams = [
              "intel_iommu=igfx_off"
            ];
            kernel.sysctl = { "vm.max_map_count" = 2147483642; };
          };
          hardware = {
            nvidia = {
              package = vulkan;
              prime = {
                inherit intelBusId;
                inherit nvidiaBusId;
                reverseSync.enable = true;
              };
              powerManagement = {
                enable = true;
                finegrained = true;
              };
              modesetting.enable = true;
              nvidiaPersistenced = true;
              forceFullCompositionPipeline = true;
              nvidiaSettings = false;
            };
            opengl = {
              driSupport = true;
              driSupport32Bit = true;
              extraPackages = with pkgs; [
                (if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11") then vaapiIntel else intel-vaapi-driver)
                libvdpau-va-gl
                intel-media-driver
                nvidia-vaapi-driver
              ];
            };
          };
          environment = {
            variables = lib.mkDefault {
              "VK_ICD_FILENAMES" = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/intel_icd.i686.json";
              VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
              # GBM_BACKEND = "nvidia-drm";
              # LIBVA_DRIVER_NAME = "nvidia";
              # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
              # NVD_BACKEND = "direct";
            };
            systemPackages = with pkgs; [
              vulkan-loader
              glxinfo
              inxi
            ];
          };
          services.xserver = {
            videoDrivers = [ "nvidia" "i915" ];
            # screenSection = ''
            #   Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
            #   Option         "AllowIndirectGLXProtocol" "off"
            #   Option         "TripleBuffer" "on"
            # '';
          };
          nixpkgs.config.packageOverrides = pkgs: {
            vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
          };
        };
      };
      nouveau-drivers = {
        configuration = {
          system.nixos.tags = [ "nouveau-drivers" ];
          boot = {
            loader.grub.configurationName = lib.mkForce "Nouveau Graphics";
            # Ensure the Nouveau module is loaded
            # kernelModules = [ "nouveau" ];

            # Blacklist the proprietary NVIDIA driver, if needed
            blacklistedKernelModules = [ "nvidia" "nvidia_uvm" "nvidia_drm" "nvidia_modeset" ];
          };

          # Configure Xorg to use the Nouveau driver
          services.xserver = {
            enable = true;
            videoDrivers = [
              # "nouveau"

              # Optional: Enable VA-API (Video Acceleration API) for better video playback performance
              # "modesetting"

              # Enable the X11 windowing system with Intel drivers
              # "intel"

              # "Intel GPU support via the i915 driver for optimal performance and feature set"
              # "i915"
            ];

            # Optional: Configure display settings, if necessary
            # displayManager = {
            #   ...
            # };
            # desktopManager = {
            #   ...
            # };
          };

          # Enable hardware acceleration for Nouveau
          hardware = {
            opengl = {
              enable = true;
              # driSupport = true;
              # driSupport32Bit = true;
              extraPackages = with pkgs; [
                # Add packages needed for Nouveau acceleration here
                # For example, Mesa for OpenGL:
                mesa
                mesa.drivers

                # (
                  # if
                    # (lib.versionOlder (lib.versions.majorMinor lib.version)
                      # "23.11")
                  # then vaapiIntel
                  # else intel-vaapi-driver
                # )
                # intel-media-driver
                # libvdpau
                # libvdpau-va-gl
              ];
            };
          };
          # Additional configurations if required
          # For example, to manage power settings for Nouveau:
          # environment.etc."modprobe.d/nouveau.conf".text = ''
          #   options nouveau modeset=1
          # '';
          # nixpkgs.config.packageOverrides = pkgs: {
            # vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
          # };
        };
      };
    };
  };
}
