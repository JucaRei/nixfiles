{ config, lib, pkgs, desktop, osConfig ? null, platform, ... }:
let
  inherit (lib) mkIf;
  backend = config.desktop.display-servers.backend;
  isNixOS = osConfig != null;
  isArm = platform == "aarch64-linux" || platform == "armv7l-linux";

  # GPU detection (NixOS: from osConfig, non-NixOS: runtime via activation)
  videoDrivers = if isNixOS then (osConfig.services.xserver.videoDrivers or [ ]) else [ ];
  hasNvidia = lib.elem "nvidia" videoDrivers;
  hasIntel = lib.elem "intel" videoDrivers;
  hasAmd = lib.elemAny [ "amdgpu" "radeon" "ati" ] videoDrivers;
  hasArmGpu = if isArm then (lib.elemAny [ "vc4" "panfrost" "rockchip" "kmsro" ] videoDrivers) else false;
  hasGpuFallback =
    if videoDrivers != [ ] && isNixOS then
      if hasNvidia then "nvidia" else if hasAmd then "amd" else if hasIntel then "intel" else if hasArmGpu then "arm" else null
    else null;
in
{
  config = mkIf (backend == "wayland") {

    home = {
      sessionVariables = {
        # Common Wayland vars
        QT_QPA_PLATFORM = "wayland;xcb"; # Prefer Wayland, fallback to XCB
        XDG_SESSION_TYPE = "wayland";
        EGL_PLATFORM = "wayland";

        # Hardware cursors fix (often for NVIDIA)
        WLR_NO_HARDWARE_CURSORS = "1"; # Often needed on ARM too

        # GPU-specific (declarative on NixOS only)
        GBM_BACKEND = mkIf isNixOS (if hasNvidia || hasGpuFallback == "nvidia" then "nvidia-drm" else if hasArmGpu || hasGpuFallback == "arm" then "gbm" else null);
        __GLX_VENDOR_LIBRARY_NAME = mkIf isNixOS (if hasNvidia || hasGpuFallback == "nvidia" then "nvidia" else null);
        __NV_PRIME_RENDER_OFFLOAD = mkIf isNixOS (if hasNvidia || hasGpuFallback == "nvidia" then "1" else null);
        __VK_LAYER_NV_optimus = mkIf isNixOS (if hasNvidia || hasGpuFallback == "nvidia" then "NVIDIA_only" else null);
        LIBVA_DRIVER_NAME = mkIf isNixOS (
          if hasIntel || hasGpuFallback == "intel" then "iHD" else
          if hasNvidia || hasGpuFallback == "nvidia" then "nvidia" else
          if hasAmd || hasGpuFallback == "amd" then "radeonsi" else
          if hasArmGpu || hasGpuFallback == "arm" then "v3d" else null
        );
        VDPAU_DRIVER = mkIf isNixOS (
          if hasNvidia || hasGpuFallback == "nvidia" then "nvidia" else
          if hasAmd || hasGpuFallback == "amd" then "radeonsi" else
          if hasArmGpu || hasGpuFallback == "arm" then "v3d" else null
        );
        MOZ_DISABLE_RDD_SANDBOX = mkIf isNixOS (if hasNvidia || hasGpuFallback == "nvidia" then "1" else null);
        WLR_BACKEND = "vulkan";
        NVD_BACKEND = mkIf isNixOS (if hasNvidia || hasGpuFallback == "nvidia" then "direct" else null);

        # Card paths (adjust PCI paths for ARM; may not apply, so conditional)
        IGPU_CARD = mkIf (!isArm) "$(${pkgs.uutils-coreutils-noprefix}/bin/readlink -f /dev/dri/by-path/pci-0000:00:02.0-card)";
        DGPU_CARD = mkIf (!isArm) "$(${pkgs.uutils-coreutils-noprefix}/bin/readlink -f /dev/dri/by-path/pci-0000:01:00.0-card)";
      };

      # Runtime detection for non-NixOS (Wayland-focused, with ARM fallback)
      activation = {
        setWaylandVars = mkIf (!isNixOS) (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -pv $HOME/.local/scripts
          cat > $HOME/.local/scripts/wayland-vars.sh <<EOF
          #!/bin/sh
          if [ -f /proc/device-tree/model ] && grep -iqE 'raspberry|nanopi|rockchip' /proc/device-tree/model; then
            # ARM board detected
            export LIBVA_DRIVER_NAME="v3d"  # Or "panfrost"
            export VDPAU_DRIVER="v3d"
            export GBM_BACKEND="gbm"
          elif command -v lspci >/dev/null 2>&1 && lspci | grep -iE 'vga.*nvidia' >/dev/null; then
            # NVIDIA
            export GBM_BACKEND="nvidia-drm"
            export __GLX_VENDOR_LIBRARY_NAME="nvidia"
            export LIBVA_DRIVER_NAME="nvidia"
            export VDPAU_DRIVER="nvidia"
            export __NV_PRIME_RENDER_OFFLOAD="1"
            export __VK_LAYER_NV_optimus="NVIDIA_only"
            export MOZ_DISABLE_RDD_SANDBOX="1"
            export NVD_BACKEND="direct"
          elif command -v lspci >/dev/null 2>&1 && lspci | grep -iE 'vga.*amd|radeon' >/dev/null; then
            # AMD
            export LIBVA_DRIVER_NAME="radeonsi"
            export VDPAU_DRIVER="radeonsi"
          elif command -v lspci >/dev/null 2>&1 && lspci | grep -iE 'vga.*intel' >/dev/null; then
            # Intel
            export LIBVA_DRIVER_NAME="iHD"
          fi
          EOF
          chmod +x $HOME/.local/scripts/wayland-vars.sh
        '');
      };

      file = {
        # Source the script in .profile (shell-agnostic, covers bash/zsh/fish/etc.)
        ".profile".text = mkIf (!isNixOS) ''
          [ -f "$HOME/.local/scripts/wayland-vars.sh" ] && . "$HOME/.local/scripts/wayland-vars.sh"
        '';
      };
    };

    services.gnome-keyring = {
      enable = mkIf ((desktop != "kde" && desktop != "pantheon") && isNixOS) true;
    };
  };
}
