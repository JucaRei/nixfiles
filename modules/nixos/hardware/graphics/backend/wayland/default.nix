{ lib, config, pkgs, namespace, ... }:
let
  inherit (lib) mkIf mkForce;
  graphics = config.${namespace}.hardware.graphics;

  # nvidia-card = "$(readlink -f /dev/dri/by-path/pci-0000:01:00.0-card)";
  nvidia-card = "/dev/dri/card1";

  gnome-desk = config.${namespace}.desktop.environment;

  gnome-gpu-rule = pkgs.writeTextFile {
    name = "61-mutter-primary-gpu.rules";
    text = ''
      ENV{DEVNAME}=="${nvidia-card}", TAG+="mutter-graphics-preferred-primary"
    '';

    destination = "/etc/udev/rules.d/61-mutter-primary-gpu.rules";
  };
in
{
  config = mkIf (graphics.backend == "wayland") {
    boot = {
      kernelParams = mkIf (graphics.gpu == "hybrid-nvidia" || graphics.gpu == "nvidia") [
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
        "NVreg_TemporaryFilePath=/var/tmp"
      ];
    };

    environment = {

      sessionVariables = rec {
        QT_QPA_PLATFORM = "wayland;xcb";

        __NV_PRIME_RENDER_OFFLOAD = (mkIf (graphics.gpu == "hybrid-nvidia")) "1";

        XDG_SESSION_TYPE = "wayland";

        # Hardware cursors are currently broken on nvidia
        WLR_NO_HARDWARE_CURSORS = "1";

        # Required to run the correct GBM backend for nvidia GPUs on wayland
        GBM_BACKEND = (mkIf (graphics.gpu == "hybrid-nvidia" || graphics.gpu == "nvidia")) "nvidia-drm";

        # Apparently, without this nouveau may attempt to be used instead
        # (despite it being blacklisted)
        __GLX_VENDOR_LIBRARY_NAME =
          let
            isNvidia = (graphics.gpu == "hybrid-nvidia") || (graphics.gpu == "nvidia");
          in
          mkIf isNvidia "nvidia";

        VDPAU_DRIVER =
          let
            isNvidia = (graphics.gpu == "hybrid-nvidia") || (graphics.gpu == "nvidia");
          in
          mkIf isNvidia "nvidia";

        # Required to use va-api it in Firefox. See
        # https://github.com/elFarto/nvidia-vaapi-driver/issues/96
        MOZ_DISABLE_RDD_SANDBOX = (mkIf (graphics.gpu == "hybrid-nvidia")) "1";

        # https://www.reddit.com/r/hyprland/comments/188a8fr/people_with_nvidia_cards_please_share_your_secret/
        # __VK_LAYER_NV_optimus = (mkIf (graphics.gpu == "hybrid-nvidia")) "NVIDIA_only";
        WLR_BACKEND = "vulkan";
        # DRI_PRIME = mkIf (graphics.gpu == "hybrid-nvidia") "pci-0000_01_00_0";

        # It appears that the normal rendering mode is broken on recent
        # nvidia drivers:
        # https://github.com/elFarto/nvidia-vaapi-driver/issues/213#issuecomment-1585584038
        NVD_BACKEND =
          let
            isNvidia = (graphics.gpu == "hybrid-nvidia") || (graphics.gpu == "nvidia");
          in
          mkIf isNvidia "direct";

        # Required for firefox 98+, see:
        # https://github.com/elFarto/nvidia-vaapi-driver#firefox
        EGL_PLATFORM = "wayland";

        # Use DGPU for wlroots window managers
        IGPU_CARD = "$(readlink -f /dev/dri/by-path/pci-0000:00:02.0-card)";
        DGPU_CARD = "$(readlink -f /dev/dri/by-path/pci-0000:01:00.0-card)";

        # WLR_DRM_DEVICES = (mkIf (graphics.gpu == "hybrid-nvidia")) "/dev/dri/card2:/dev/dri/card1";
        WLR_DRM_DEVICES = (mkIf (graphics.gpu == "hybrid-nvidia")) "${DGPU_CARD}:${IGPU_CARD}";

        # Tells every app to use my iGPU unless I specially instruct it not to
        # I would have to use the `nvidia-offload` command
        # This also speeds up the startup time of apps using GPU, because my nvidia card is always powered off
        # source: https://sw.kovidgoyal.net/kitty/faq/#why-does-kitty-sometimes-start-slowly-on-my-linux-system
        # source: https://github.com/Einjerjar/nix/blob/172d17410cd0849f7028f80c0e2084b4eab27cc7/home/vars.nix#L30
        # source: https://github.com/NixOS/nixpkgs/pull/139354#issuecomment-926942682
        # __EGL_VENDOR_LIBRARY_FILENAMES = "${config.hardware.graphics.package}/share/glvnd/egl_vendor.d/50_mesa.json:${config.hardware.nvidia.package}/share/glvnd/egl_vendor.d/10_nvidia.json";
        # __EGL_VENDOR_LIBRARY_FILENAMES = (mkIf (graphics.gpu == "hybrid-nvidia")) "${config.hardware.nvidia.package}/share/glvnd/egl_vendor.d/10_nvidia.json";

        __EGL_VENDOR_LIBRARY_FILENAMES = (mkIf (graphics.gpu == "hybrid-nvidia")) "${config.hardware.nvidia.package}/share/glvnd/egl_vendor.d/10_nvidia.json:${config.hardware.graphics.package}/share/glvnd/egl_vendor.d/50_mesa.json";
      };

      pathsToLink = [ "/libexec" ];

      shellAliases = {
        check-drm = mkForce "${pkgs.drm_info}/bin/drm_info -j | ${pkgs.jq}/bin/jq 'with_entries(.value |= .driver.desc)'";
      };
    };

    services = mkIf (gnome-desk && config.hardware.graphics.gpu == "hybrid-nvidia") {
      # services = mkIf (config.hardware.graphics.gpu == "hybrid-nvidia") {
      udev.packages = [ gnome-gpu-rule ];
    };
  };
}
