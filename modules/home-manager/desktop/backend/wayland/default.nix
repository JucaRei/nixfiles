{ config, lib, pkgs, desktop, osConfig ? null, platform, ... }:
let
  inherit (lib) mkIf;
  backend = config.desktop.backend;
  isNixOS = osConfig != null;
  isArm = platform == "aarch64-linux" || platform == "armv7l-linux";

  # GPU detection (NixOS: from osConfig, non-NixOS: runtime via activation)
  videoDrivers = if isNixOS then (osConfig.services.xserver.videoDrivers or [ ]) else [ ];
  hasNvidia = lib.elem "nvidia" videoDrivers;
  hasIntel = lib.elem "intel" videoDrivers;
  hasAmd = lib.any (elem: lib.elem elem videoDrivers) [ "amdgpu" "radeon" "ati" ];
  hasArmGpu = if isArm then (lib.any (elem: lib.elem elem videoDrivers) [ "vc4" "panfrost" "rockchip" "kmsro" ]) else false;
  hasGpuFallback =
    if videoDrivers != [ ] && isNixOS then
      if hasNvidia then "nvidia" else if hasAmd then "amd" else if hasIntel then "intel" else if hasArmGpu then "arm" else null
    else null;
in
{
  config = mkIf (backend == "wayland") {

    home = {
      sessionVariables = lib.filterAttrs (n: v: v != null) {
        # Common Wayland vars
        QT_QPA_PLATFORM = "wayland;xcb"; # Prefer Wayland, fallback to XCB
        XDG_SESSION_TYPE = "wayland";
        EGL_PLATFORM = "wayland";

        # Hardware cursors fix (often for NVIDIA)
        WLR_NO_HARDWARE_CURSORS = "1"; # Often needed on ARM too

        # GPU-specific (declarative on NixOS only)
        GBM_BACKEND = if isNixOS then (if hasNvidia || hasGpuFallback == "nvidia" then "nvidia-drm" else if hasArmGpu || hasGpuFallback == "arm" then "gbm" else null) else null;
        __GLX_VENDOR_LIBRARY_NAME = if isNixOS then (if hasNvidia || hasGpuFallback == "nvidia" then "nvidia" else null) else null;
        __NV_PRIME_RENDER_OFFLOAD = if isNixOS then (if hasNvidia || hasGpuFallback == "nvidia" then "1" else null) else null;
        __VK_LAYER_NV_optimus = if isNixOS then (if hasNvidia || hasGpuFallback == "nvidia" then "NVIDIA_only" else null) else null;
        LIBVA_DRIVER_NAME = if isNixOS then (
          if hasIntel || hasGpuFallback == "intel" then "iHD" else
          if hasNvidia || hasGpuFallback == "nvidia" then "nvidia" else
          if hasAmd || hasGpuFallback == "amd" then "radeonsi" else
          if hasArmGpu || hasGpuFallback == "arm" then "v3d" else null
        ) else null;
        VDPAU_DRIVER = if isNixOS then (
          if hasNvidia || hasGpuFallback == "nvidia" then "nvidia" else
          if hasAmd || hasGpuFallback == "amd" then "radeonsi" else
          if hasArmGpu || hasGpuFallback == "arm" then "v3d" else null
        ) else null;
        MOZ_DISABLE_RDD_SANDBOX = if isNixOS then (if hasNvidia || hasGpuFallback == "nvidia" then "1" else null) else null;
        WLR_BACKEND = "vulkan";
        NVD_BACKEND = if isNixOS then (if hasNvidia || hasGpuFallback == "nvidia" then "direct" else null) else null;

        # Card paths (adjust PCI paths for ARM; may not apply, so conditional)
        IGPU_CARD = if (!isArm) then "$(${pkgs.uutils-coreutils-noprefix}/bin/readlink -f /dev/dri/by-path/pci-0000:00:02.0-card)" else null;
        DGPU_CARD = if (!isArm) then "$(${pkgs.uutils-coreutils-noprefix}/bin/readlink -f /dev/dri/by-path/pci-0000:01:00.0-card)" else null;
      };

      # Runtime detection for non-NixOS (Wayland-focused, with ARM fallback)
      activation = mkIf (!isNixOS) {
        setWaylandVars = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
        '';
      };

      file = mkIf (!isNixOS) {
        # Source the script in .profile (shell-agnostic, covers bash/zsh/fish/etc.)
        ".profile".text = ''
          [ -f "$HOME/.local/scripts/wayland-vars.sh" ] && . "$HOME/.local/scripts/wayland-vars.sh"
        '';
      };
    };

    services.gnome-keyring = {
      enable = (desktop != "kde" && desktop != "pantheon") && isNixOS;
    };
  };
}
