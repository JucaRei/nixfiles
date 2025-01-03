{ lib, config, pkgs, ... }:
let
  inherit (lib) mkIf mkForce mkDefault;
  device = config.features.graphics;
in
{
  config = mkIf (device.backend == "wayland") {
    environment = {

      sessionVariables = {
        QT_QPA_PLATFORM = "wayland";

        __NV_PRIME_RENDER_OFFLOAD = (mkIf (device.gpu == "hybrid-nvidia")) "1";

        # Hardware cursors are currently broken on nvidia
        WLR_NO_HARDWARE_CURSORS = "1";

        # Required to run the correct GBM backend for nvidia GPUs on wayland
        GBM_BACKEND = (mkIf ((device.gpu == "hybrid-nvidia") || (device.gpu == "nvidia"))) "nvidia-drm";

        # Apparently, without this nouveau may attempt to be used instead
        # (despite it being blacklisted)
        __GLX_VENDOR_LIBRARY_NAME =
          let
            isNvidia = device.gpu == "hybrid-nvidia" || device.gpu == "nvidia";
          in
          mkIf (isNvidia) "nvidia";

        # Required to use va-api it in Firefox. See
        # https://github.com/elFarto/nvidia-vaapi-driver/issues/96
        # MOZ_DISABLE_RDD_SANDBOX = "1";

        # It appears that the normal rendering mode is broken on recent
        # nvidia drivers:
        # https://github.com/elFarto/nvidia-vaapi-driver/issues/213#issuecomment-1585584038
        NVD_BACKEND =
          let
            isNvidia = device.gpu == "hybrid-nvidia" || device.gpu == "nvidia";
          in
          mkIf isNvidia "direct";

        # Required for firefox 98+, see:
        # https://github.com/elFarto/nvidia-vaapi-driver#firefox
        EGL_PLATFORM = "wayland";

        WLR_DRM_DEVICES = (mkIf (device.gpu == "hybrid-nvidia")) "/dev/dri/card2:/dev/dri/card1";
      };

      pathsToLink = [ "/libexec" ];

      shellAliases = {
        check-drm = mkForce "${pkgs.drm_info}/bin/drm_info -j | ${pkgs.jq}/bin/jq 'with_entries(.value |= .driver.desc)'";
      };
    };

  };
}
