{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia "$@"
    exit 0
  '';
  nvidiaBusId = "PCI:1:0:0";
in {
  specialisation = {
    nvidia-legacy.configuration = {
      system.nixos.tags = ["nvidia-legacy"];
      hardware = {
        nvidia = {
          # package = config.boot.linuxKernel.packages.linux_xanmod_stable.nvidia_x11_legacy340;
          package = config.boot.kernelPackages.nvidiaPackages.legacy_340;
          # Enable the nvidia settings menu
          nvidiaSettings = true;
          forceFullCompositionPipeline = true;
          nvidiaPersistenced = true;
          powerManagement = {
            enable = false;
            finegrained = false;
          };
          # Modesetting is needed for most Wayland compositors
          modesetting.enable = true;
        };
      };

      services = {
        xserver = {
          deviceSection = lib.mkDefault ''
            Option "TearFree" "true"
          '';
          config = ''
            Section "Device"
              Identifier "Nvidia Card"
              Driver "nvidia"
              VendorName "NVIDIA Corporation"
              Option "RegistryDwords" "EnableBrightnessControl=1"
            EndSection
          '';

          # videoDrivers = [ "nvidia" ];
          screenSection = ''
            Option     "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
          '';
        };
      };

      environment.systemPackages = with pkgs; [glxinfo sdlmame];

      boot = {
        loader.grub.configurationName = lib.mkForce "Nouveau Driver";
        # blacklistedKernelModules = [ "nouveau" "i915" ];
        kernelParams = ["nvidia"];
        extraModprobeConfig = ''
          blacklist nouveau
          options nouveau modeset=0
          options nvidia-drm modeset=1
        '';
        extraModulePackages = [config.boot.kernelPackages.nvidia_x11_legacy340];
      };

      virtualisation.docker.enableNvidia = true;
    };
    noveau-driver.configuration = {
      system.nixos.tags = ["noveau-driver"];
      boot.loader.grub.configurationName = lib.mkForce "Nouveau Driver";
      services = {
        xserver = {
          videoDrivers = ["nouveau"];
          # screenSection = ''
          #   Option     "CurrentMetaMode" "1920 x 1200+0+0 {ForceFullCompositionPipeline=On}
          # '';
        };
      };
      environment = {
        etc."X11/xorg.config.d/20-nouveau.conf" = {
          text = ''
            Section "Device"
              Identifier "nvidia card"
              Driver "nouveau"
              Option "GLXVBlank" "true"
            EndSection
          '';
        };
        systemPackages = with pkgs; [
          mesa
          libdrm
          driversi686Linux.mesa
          xorg.xf86videonouveau
        ];
      };
    };
  };
}
