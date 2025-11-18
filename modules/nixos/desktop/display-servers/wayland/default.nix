{ config, lib, pkgs, desktop, ... }:
let
  inherit (lib) mkIf mkForce;
  graphics = config.hardware.graphics.cards;
  backend = config.desktop.display-servers.backend;

  nvidia-card = "$(${pkgs.uutils-coreutils-noprefix}/bin/readlink -f /dev/dri/by-path/pci-0000:01:00.0-card)";
  # nvidia-card = "/dev/dri/card1";

  gnome-gpu-rule = pkgs.writeTextFile {
    name = "61-mutter-primary-gpu.rules";
    text = ''
      ENV{DEVNAME}=="${nvidia-card}", TAG+="mutter-graphics-preferred-primary"
    '';

    destination = "/etc/udev/rules.d/61-mutter-primary-gpu.rules";
  };
in
{
  config = mkIf (backend == "wayland") {
    boot = {
      kernelParams = mkIf (graphics.gpu == "hybrid-nvidia" || graphics.gpu == "nvidia") [
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
        "NVreg_TemporaryFilePath=/var/tmp"
      ];
    };

    environment = {
      sessionVariables =
        let
          isNvidia = (graphics.gpu == "hybrid-nvidia") || (graphics.gpu == "nvidia");
        in
        rec {
          QT_QPA_PLATFORM = "wayland;xcb";
          __NV_PRIME_RENDER_OFFLOAD = (mkIf (graphics.gpu == "hybrid-nvidia")) "1";
          XDG_SESSION_TYPE = "wayland";
          WLR_NO_HARDWARE_CURSORS = "1"; # Hardware cursors are currently broken on nvidia
          GBM_BACKEND = (mkIf (isNvidia)) "nvidia-drm"; # Required to run the correct GBM backend for nvidia GPUs on wayland
          # Apparently, without this nouveau may attempt to be used instead
          # (despite it being blacklisted)
          __GLX_VENDOR_LIBRARY_NAME = mkIf (isNvidia) "nvidia";
          VDPAU_DRIVER = mkIf (isNvidia) "nvidia";
          MOZ_DISABLE_RDD_SANDBOX = (mkIf (graphics.gpu == "hybrid-nvidia")) "1";
          WLR_BACKEND = "vulkan";
          NVD_BACKEND = mkIf (isNvidia) "direct";
          EGL_PLATFORM = "wayland";
          IGPU_CARD = "$(${pkgs.uutils-coreutils-noprefix}/bin/readlink -f /dev/dri/by-path/pci-0000:00:02.0-card)";
          DGPU_CARD = "$(${pkgs.uutils-coreutils-noprefix}/bin/readlink -f /dev/dri/by-path/pci-0000:01:00.0-card)";
          WLR_DRM_DEVICES = (mkIf (graphics.gpu == "hybrid-nvidia")) "${DGPU_CARD}:${IGPU_CARD}";
          __EGL_VENDOR_LIBRARY_FILENAMES = (mkIf (graphics.gpu == "hybrid-nvidia")) "${config.hardware.nvidia.package}/share/glvnd/egl_vendor.d/10_nvidia.json:${config.hardware.graphics.package}/share/glvnd/egl_vendor.d/50_mesa.json";
        };
      pathsToLink = [ "/libexec" ];
      shellAliases = {
        check-drm = mkForce "${pkgs.drm_info}/bin/drm_info -j | ${pkgs.jq}/bin/jq 'with_entries(.value |= .driver.desc)'";
      };
    };
    services = mkIf (desktop == "gnome" && graphics.gpu == "hybrid-nvidia") {
      udev.packages = [ gnome-gpu-rule ];
    };
  };
}
