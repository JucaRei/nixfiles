{ config, lib, pkgs, isWorkstation, ... }:
let
  inherit (lib) mkIf mkMerge mkDefault optional;
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
  # backend = config.features.display-server.manager;
in
{
  config = mkIf (device.gpu == "nvidia" || device.gpu == "hybrid-nvidia") {
    nixpkgs.config.allowUnfree = true;

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
    };

    environment = {
      sessionVariables = mkMerge [
        ({
          LIBVA_DRIVER_NAME = "nvidia";
        })

        # (mkIf (backend == "wayland") {
        #   WLR_NO_HARDWARE_CURSORS = "1";
        #   #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
        #   #GBM_BACKEND = "nvidia-drm"; # breaks firefox apparently
        # })

        # (mkIf ((backend == "wayland") && (device.gpu == "hybrid-nvidia") && (config.features.graphics.enable)) {
        #   __NV_PRIME_RENDER_OFFLOAD = "1";
        #   WLR_DRM_DEVICES = mkDefault "/dev/dri/card1:/dev/dri/card0";
        # })
      ];

      systemPackages = with pkgs; mkIf (config.features.graphics.enable) [
        libva
        libva-utils
        vulkan-loader
        vulkan-tools
        vulkan-validation-layers
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
        prime.offload.enableOffloadCmd = device.gpu == "hybrid-nvidia";
        powerManagement = {
          enable = mkDefault true;
          finegrained = device.gpu == "hybrid-nvidia";
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
