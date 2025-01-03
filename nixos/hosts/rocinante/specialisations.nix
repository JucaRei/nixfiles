{ lib, pkgs, ... }:
let
  inherit (lib) mkForce;
in
{
  specialisation = {
    nouveau-drivers = {
      configuration = {
        system.nixos.tags = [ "nouveau-drivers" ];
        boot = {
          # kernelParams = [
          #   "nouveau.modeset=1"
          #   "nouveau.config=NvGspRm=1" # New unstable nouveau
          # ];
          # initrd = {
          #   kernelModules = [ "nouveau" ];
          # };
          blacklistedKernelModules = [ "nvidia" "nvidia_uvm" "nvidia_drm" "nvidia_modeset" ];
          loader.grub.configurationName = mkForce "Nouveau Drivers";
        };
        services = {
          xserver = {
            videoDrivers = [
              "nouveau"
              # "modesetting"
            ];
            # screenSection = ''
            #   Option     "CurrentMetaMode" "1920 x 1200+0+0 {ForceFullCompositionPipeline=On}
            # '';
            config = ''
              Section "Device"
                Identifier "Nvidia 8600 GT"
                Driver "nouveau"
              EndSection
            '';
          };
        };
        environment = {
          etc."X11/xorg.config.d/20-nouveau.conf" = {
            text = ''
              Section "Device"
                # Identifier "Nvidia 8600 GT"
                Identifier "Nvidia Card"
                Driver "nouveau"
                Option "GLXVBlank" "true"
              EndSection
            '';
          };

          # sessionVariables = {
          #   VDPAU_DRIVER = "nouveau";
          #   LIBVA_DRIVER_NAME = "nouveau";
          # };
          variables = {
            VDPAU_DRIVER = mkForce "nouveau";
            LIBVA_DRIVER_NAME = mkForce "nouveau";
            __GL_GSYNC_ALLOWED = 0;
            __GL_SYNC_TO_VBLANK = 0;
            __GL_VRR_ALLOWED = 0;
            MOZ_DISABLE_RDD_SANDBOX = 1;
            NVD_BACKEND = "direct";
          };

          systemPackages = with pkgs // pkgs.driversi686Linux; [
            # mesa # Enables mesa
            # mesa_git.drivers # Enables the use of mesa drivers
            mesa_git # Enables mesa
            libdrm_git
            libdrm32_git
            mesa32_git
            # xorg.xf86videonouveau
            glxinfo

            # nvidia-vaapi-driver # Not sure if this is needed
            # vaapiVdpau # Not sure if this is needed
            # libvdpau-va-gl # Not sure if this is needed
          ];
        };
        # chaotic.mesa-git.enable = true;
      };
    };
  };
}
