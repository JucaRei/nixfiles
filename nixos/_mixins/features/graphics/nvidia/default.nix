{ config, lib, pkgs, isWorkstation, ... }:
let
  inherit (lib) mkIf mkMerge mkDefault mkForce optional mkOption types;
  nvStable = config.boot.kernelPackages.nvidiaPackages.stable.version;
  nvBeta = config.boot.kernelPackages.nvidiaPackages.beta.version;

  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';

  nvidiaPackage =
    if (lib.strings.versionOlder nvBeta nvStable)
    then config.boot.kernelPackages.nvidiaPackages.stable
    else config.boot.kernelPackages.nvidiaPackages.beta;

  device = config.features.graphics;
  backend = config.features.graphics.backend;
in
{
  options = {
    features.graphics.backend = mkOption {
      type = types.enum [ "x11" "wayland" ];
      default = "x11";
      description = "Default backend for the system";
    };
  };

  config = mkIf (device.gpu == "nvidia" || device.gpu == "hybrid-nvidia") {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.nvidia.acceptLicense = true;

    services.xserver = mkMerge [
      {
        videoDrivers = [ "nvidia" ];
      }

      # (mkIf (isWorkstation) {
      #   deviceSection = ''
      #     Option "TearFree" "true"
      #   '';
      #   config = ''
      #     Section "Device"
      #       # Identifier "Nvidia Card"
      #       # Driver "nvidia"
      #       # VendorName "NVIDIA Corporation"
      #       Option "RegistryDwords" "EnableBrightnessControl=1"
      #     EndSection
      #   ''; # enables  brightness control
      # })
      # (mkIf (backend == "x11") {
      #   # disable DPMS
      #   monitorSection = ''
      #     Option "DPMS" "false"
      #   '';

      #   # disable screen blanking in general
      #   serverFlagsSection = ''
      #     Option "StandbyTime" "0"
      #     Option "SuspendTime" "0"
      #     Option "OffTime" "0"
      #     Option "BlankTime" "0"
      #   '';
      # })
    ];

    boot = {
      blacklistedKernelModules = [
        "nouveau"
      ];
      # initrd.kernelModules = [ "nvidia" "nvidia_drm" "nvidia_uvm" "nvidia_modeset" ];
      kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" ];

      extraModprobeConfig =
        "options nvidia "
        + lib.concatStringsSep " " [
          # nvidia assume that by default your CPU does not support PAT,
          # but this is effectively never the case in 2023
          "NVreg_UsePageAttributeTable=1"
          # This is sometimes needed for ddc/ci support, see
          # https://www.ddcutil.com/nvidia/
          #
          # Current monitor does not support it, but this is useful for
          # the future
          "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"
        ];
    };

    environment = {
      sessionVariables = mkMerge [
        ({
          LIBVA_DRIVER_NAME = "nvidia";
        })

        # NVD_BACKEND = "direct";

        (mkIf (backend == "wayland") {
          # Necessary to correctly enable va-api (video codec hardware
          # acceleration). If this isn't set, the libvdpau backend will be
          # picked, and that one doesn't work with most things, including
          # Firefox.
          __NV_PRIME_RENDER_OFFLOAD = (mkIf (device.gpu == "hybrid-nvidia")) "1";

          # Hardware cursors are currently broken on nvidia
          WLR_NO_HARDWARE_CURSORS = "1";
          # Required to run the correct GBM backend for nvidia GPUs on wayland
          GBM_BACKEND = "nvidia-drm";
          # Apparently, without this nouveau may attempt to be used instead
          # (despite it being blacklisted)
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";

          # Required to use va-api it in Firefox. See
          # https://github.com/elFarto/nvidia-vaapi-driver/issues/96
          MOZ_DISABLE_RDD_SANDBOX = "1";

          # It appears that the normal rendering mode is broken on recent
          # nvidia drivers:
          # https://github.com/elFarto/nvidia-vaapi-driver/issues/213#issuecomment-1585584038
          NVD_BACKEND = "direct";

          # Required for firefox 98+, see:
          # https://github.com/elFarto/nvidia-vaapi-driver#firefox
          EGL_PLATFORM = "wayland";

          # WLR_DRM_DEVICES = mkDefault "/dev/dri/card1:/dev/dri/card0";
          WLR_DRM_DEVICES = (mkIf (device.gpu == "hybrid-nvidia")) "/dev/dri/card2:/dev/dri/card1"; # Default nvidia
          # WLR_DRM_DEVICES = "/dev/dri/by-path/{pci-*-card}";
        })

      ];

      systemPackages = with pkgs; mkIf (config.features.graphics.enable) [
        libva
        libva-utils
        vulkan-loader
        vulkan-tools
        vulkan-validation-layers
        # (writeScriptBin "nvidia-settings" ''
        #   #!${stdenv.shell}
        #   mkdir -p "$XDG_CONFIG_HOME/nvidia"
        #   exec ${config.boot.kernelPackages.nvidia_x11.settings}/bin/nvidia-settings --config="$XDG_CONFIG_HOME/nvidia/settings"
        # '')
      ]
        # ++ optional (device.gpu == "hybrid-nvidia") [
        #   nvidia-offload
        # ]
      ;
    };

    hardware = {
      nvidia = {
        package = mkDefault nvidiaPackage;
        modesetting.enable = mkDefault true;
        prime = {
          offload = {
            enable = if (device.gpu == "hybrid-nvidia") then true else false;
            enableOffloadCmd = if (device.gpu == "hybrid-nvidia") then true else false;
          };
          # reverseSync.enable = if (device.gpu == "hybrid-nvidia") then true else false;
        };
        powerManagement = {
          enable = mkDefault true;
          finegrained = if (device.gpu == "hybrid-nvidia") then true else false;
        };

        open = mkDefault false;
        nvidiaSettings = false;
        nvidiaPersistenced = true;
        forceFullCompositionPipeline = true;
      };

      opengl = {
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
        ];
      };
    };
  };
}
