{ lib, config, pkgs, ... }:
let
  inherit (lib) mkIf mkForce mkDefault;
  device = config.features.graphics;
in
{
  config = mkIf (device.backend == "wayland") {
    boot = {
      kernelParams = mkIf ((device.gpu == "hybrid-nvidia") || (device.gpu == "nvidia")) [
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
        "NVreg_TemporaryFilePath=/var/tmp"
      ];
    };

    environment = {

      sessionVariables = rec {
        QT_QPA_PLATFORM = "wayland";

        __NV_PRIME_RENDER_OFFLOAD = (mkIf (device.gpu == "hybrid-nvidia")) "1";

        XDG_SESSION_TYPE = "wayland";

        # Hardware cursors are currently broken on nvidia
        WLR_NO_HARDWARE_CURSORS = "1";

        # Required to run the correct GBM backend for nvidia GPUs on wayland
        GBM_BACKEND = (mkIf ((device.gpu == "hybrid-nvidia") || (device.gpu == "nvidia"))) "nvidia-drm";

        # WLR_BACKEND = "vulkan";

        # Apparently, without this nouveau may attempt to be used instead
        # (despite it being blacklisted)
        __GLX_VENDOR_LIBRARY_NAME =
          let
            isNvidia = device.gpu == "hybrid-nvidia" || device.gpu == "nvidia";
          in
          mkIf (isNvidia) "nvidia";

        VDPAU_DRIVER =
          let
            isNvidia = device.gpu == "hybrid-nvidia" || device.gpu == "nvidia";
          in
          mkIf (isNvidia) "nvidia";

        # Required to use va-api it in Firefox. See
        # https://github.com/elFarto/nvidia-vaapi-driver/issues/96
        MOZ_DISABLE_RDD_SANDBOX = (mkIf (device.gpu == "hybrid-nvidia")) "1";

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

        # Use DGPU for wlroots window managers
        IGPU_CARD = "$(readlink -f /dev/dri/by-path/pci-0000:00:02.0-card)";
        DGPU_CARD = "$(readlink -f /dev/dri/by-path/pci-0000:01:00.0-card)";

        # WLR_DRM_DEVICES = (mkIf (device.gpu == "hybrid-nvidia")) "/dev/dri/card2:/dev/dri/card1";
        WLR_DRM_DEVICES = (mkIf (device.gpu == "hybrid-nvidia")) "${DGPU_CARD}:${IGPU_CARD}";

        # Tells every app to use my iGPU unless I specially instruct it not to
        # I would have to use the `nvidia-offload` command
        # This also speeds up the startup time of apps using GPU, because my nvidia card is always powered off
        # source: https://sw.kovidgoyal.net/kitty/faq/#why-does-kitty-sometimes-start-slowly-on-my-linux-system
        # source: https://github.com/Einjerjar/nix/blob/172d17410cd0849f7028f80c0e2084b4eab27cc7/home/vars.nix#L30
        # source: https://github.com/NixOS/nixpkgs/pull/139354#issuecomment-926942682
        # __EGL_VENDOR_LIBRARY_FILENAMES = "${config.hardware.graphics.package}/share/glvnd/egl_vendor.d/50_mesa.json:${config.hardware.nvidia.package}/share/glvnd/egl_vendor.d/10_nvidia.json";
        # __EGL_VENDOR_LIBRARY_FILENAMES = (mkIf (device.gpu == "hybrid-nvidia")) "${config.hardware.nvidia.package}/share/glvnd/egl_vendor.d/10_nvidia.json";

        __EGL_VENDOR_LIBRARY_FILENAMES = (mkIf (device.gpu == "hybrid-nvidia")) "${config.hardware.nvidia.package}/share/glvnd/egl_vendor.d/10_nvidia.json:${config.hardware.graphics.package}/share/glvnd/egl_vendor.d/50_mesa.json";
      };



      pathsToLink = [ "/libexec" ];

      shellAliases = {
        check-drm = mkForce "${pkgs.drm_info}/bin/drm_info -j | ${pkgs.jq}/bin/jq 'with_entries(.value |= .driver.desc)'";
      };
    };

  };
}
