{ pkgs, config, lib, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json"
    export LIBVA_DRIVER_NAME="nvidia"
    exec "$@"
  '';
in {
  boot = {
    blacklistedKernelModules =
      [ "nouveau" "rivafb" "nvidiafb" "rivatv" "nv" "uvcvideo" ];
    kernelModules = [
      "clearcpuid=514" # Fixes certain wine games crash on launch
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];
    kernelParams = [ "nvidia_drm.modeset=1" "nouveau.modeset=0" ];
    extraModprobeConfig = ''
      options nvidia NVreg_RegistryDwords="PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerLevel=0x3; PowerMizerDefault=0x3; PowerMizerDefaultAC=0x3"
      options nvidia NVreg_UsePageAttributeTable=1
      options nvidia-drm modeset=1
      options nvidia NVreg_PreserveVideoMemoryAllocations=1
      options nvidia NVreg_RegistryDwords="OverrideMaxPerf=0x1"
      options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
    '';
    # env = LIBVA_DRIVER_NAME,nvidia
    # env = XDG_SESSION_TYPE,wayland
    # env = GBM_BACKEND,nvidia-drm
    # env = __GLX_VENDOR_LIBRARY_NAME,nvidia
    # env = WLR_NO_HARDWARE_CURSORS,1
    kernel.sysctl = { "vm.max_map_count" = 2147483642; };
  };
  hardware = {
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
    };
  };
  services = {
    xserver = {
      videoDrivers = [ "nvidia" ];
      # Comment this for AMD GPU
      # This helps fix tearing of windows for Nvidia cards
      screenSection = ''
        Option       "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
        Option       "AllowIndirectGLXProtocol" "off"
        Option       "TripleBuffer" "on"
      '';
    };
  };
  environment = {
    variables = {
      "VK_ICD_FILENAMES" =
        "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/intel_icd.i686.json";
      GBM_BACKEND = "nvidia-drm";
      # GBM_BACKEND = "nvidia";
      LIBVA_DRIVER_NAME = lib.mkForce "nvidia-drm";
      # LIBVA_DRIVER_NAME = lib.mkForce "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVD_BACKEND = "direct";
      # WLR_RENDERER = "vulkan";
      __GL_GSYNC_ALLOWED = "0";
      __GL_VRR_ALLOWED = "0";
      QT_QPA_PLATFORM = "wayland";
    };
    systemPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
      glxinfo
      inxi
    ];
  };

  # Set nvidia gpu power limit
  #   systemd.services.nv-power-limit =
  #     lib.mkIf config.hardware.gpu.nvidia.powerLimit.enable {
  #       enable = true;
  #       description = "Nvidia power limit control";
  #       after = [ "syslog.target" "systemd-modules-load.service" ];

  #       unitConfig = {
  #         ConditionPathExists =
  #           "${config.boot.kernelPackages.nvidia_x11.bin}/bin/nvidia-smi";
  #       };

  #       serviceConfig = {
  #         User = "root";
  #         ExecStart =
  #           "${config.boot.kernelPackages.nvidia_x11.bin}/bin/nvidia-smi  --power-limit=${config.hardware.gpu.nvidia.powerLimit.value}";
  #       };

  #       wantedBy = [ "multi-user.target" ];
  #     };
}
