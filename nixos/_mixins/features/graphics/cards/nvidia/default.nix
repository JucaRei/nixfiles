{ config, lib, pkgs, ... }:
let
  inherit (lib) mkForce mkIf mkMerge mkDefault optionals;
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

  config = mkIf (device.gpu == "nvidia" || device.gpu == "hybrid-nvidia") {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.nvidia.acceptLicense = true;

    services.xserver = mkMerge [{
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

      (mkIf (backend == "x11") {
        # disable DPMS
        monitorSection = ''
          Option "DPMS" "false"
        '';

        # disable screen blanking in general
        serverFlagsSection = ''
          Option "StandbyTime" "0"
          Option "SuspendTime" "0"
          Option "OffTime" "0"
          Option "BlankTime" "0"
        '';
      })];

    boot = {
      blacklistedKernelModules = mkForce [
        "nouveau"
      ];
      initrd.kernelModules = [ "nvidia" "nvidia_drm" "nvidia_uvm" "nvidia_modeset" ];
      kernelParams = [
        "nvidia-drm.modeset=1"
        "nvidia-drm.fbdev=1"
      ];

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
      sessionVariables = {
        LIBVA_DRIVER_NAME = mkIf (device.gpu == "nvidia") || (device.gpu == "hybrid-nvidia" && !config.hardware.nvidia.prime.offload.enable) "nvidia";
      };

      systemPackages = with pkgs; optionals (config.hardware.nvidia.nvidiaSettings) [
        (writeScriptBin "nvidia-settings" ''
          #!${stdenv.shell}
          mkdir -p "$XDG_CONFIG_HOME/nvidia"
          exec ${config.boot.kernelPackages.nvidia_x11.settings}/bin/nvidia-settings --config="$XDG_CONFIG_HOME/nvidia/settings"
        '')
      ]
      ++
      optionals (device.gpu == "hybrid-nvidia") [ nvidia-offload ]
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
          # Make the Intel iGPU default. The NVIDIA Quadro is for CUDA/NVENC
          reverseSync.enable = if (device.gpu == "hybrid-nvidia" && !config.hardware.nvidia.prime.offload.enable) then true else false;
        };
        powerManagement = {
          enable = mkDefault true;
          finegrained = if (device.gpu == "hybrid-nvidia") then true else false;
        };

        open = mkDefault false;
        nvidiaSettings = mkDefault false;
        nvidiaPersistenced = true;
        forceFullCompositionPipeline = true;
      };

      graphics = {
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
        ];
      };
    };
  };
}
