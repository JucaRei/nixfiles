{ config, lib, pkgs, desktop, osConfig ? null, platform, ... }:
let
  inherit (lib) mkIf;
  backend = config.desktop.backend;
  graphics = config.hardware.graphics.cards;
  isNixOS = osConfig != null;
  isArm = platform == "aarch64-linux" || platform == "armv7l-linux"; # From flake arg

  # GPU detection (NixOS: from osConfig, non-NixOS: runtime via activation)
  videoDrivers = if isNixOS then (osConfig.services.xserver.videoDrivers or [ ]) else [ ];
  hasNvidia = lib.elem "nvidia" videoDrivers;
  hasIntel = lib.elem "intel" videoDrivers;
  hasAmd = lib.elemAny [ "amdgpu" "radeon" "ati" ] videoDrivers;
  hasArmGpu = if isArm then (lib.elemAny [ "vc4" "panfrost" "rockchip" "kmsro" ] videoDrivers) else false; # RPi/NanoPi drivers
  # Fallback: Prioritize NVIDIA > AMD > Intel > ARM
  hasGpuFallback =
    if videoDrivers != [ ] && isNixOS then
      if hasNvidia then "nvidia" else if hasAmd then "amd" else if hasIntel then "intel" else if hasArmGpu then "arm" else null
    else null;
in
{
  config = mkIf (backend == "x11") {
    home = {
      packages = with pkgs ;(mkIf (desktop == "bspwm") [
        wmctrl
        notify-desktop
        xdotool
        ydotool
      ]) ++
      (mkIf (!isNixOS) [
        # For lspci on non-NixOS + glxinfo for ARM detection
        pciutils
        glxinfo
      ]);

      # Fix issue with java applications and tiling window managers.
      sessionVariables = {
        "_JAVA_AWT_WM_NONREPARENTING" = (mkIf (desktop == "bspwm")) "1"; # Java fix for non-reparenting WMs (bspwm, etc.)

        # Hardware acceleration (declarative on NixOS only)
        LIBVA_DRIVER_NAME = mkIf isNixOS (
          if hasIntel || hasGpuFallback == "intel" then "iHD" else
          if hasNvidia || hasGpuFallback == "nvidia" then "nvidia" else
          if hasAmd || hasGpuFallback == "amd" then "radeonsi" else
          if hasArmGpu || hasGpuFallback == "arm" then "v3d"  # Or "panfrost" for Mali/NanoPi
          else null
        );

        VDPAU_DRIVER = mkIf isNixOS (
          if hasNvidia || hasGpuFallback == "nvidia" then "nvidia" else
          if hasAmd || hasGpuFallback == "amd" then "radeonsi" else
          if hasArmGpu || hasGpuFallback == "arm" then "v3d"  # Adjust for NanoPi
          else null
        );

        # Runtime GPU detection for non-NixOS (X11-focused, with ARM fallback)
        activation.setX11Vars = mkIf (!isNixOS) (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          # Create script directory and generate GPU env script
          mkdir -pv $HOME/.local/scripts
          cat > $HOME/.local/scripts/x11-vars.sh <<EOF
          #!/bin/sh
          if [ -f /proc/device-tree/model ] && grep -iqE 'raspberry|nanopi|rockchip' /proc/device-tree/model; then
            # ARM board detected (RPi/NanoPi)
            export LIBVA_DRIVER_NAME="v3d"  # Or "panfrost" for Mali
            export VDPAU_DRIVER="v3d"
          elif command -v lspci >/dev/null 2>&1 && lspci | grep -iE 'vga.*nvidia' >/dev/null; then
            # NVIDIA
            export LIBVA_DRIVER_NAME="nvidia"
            export VDPAU_DRIVER="nvidia"
            export __GLX_VENDOR_LIBRARY_NAME="nvidia"
          elif command -v lspci >/dev/null 2>&1 && lspci | grep -iE 'vga.*amd|radeon' >/dev/null; then
            # AMD
            export LIBVA_DRIVER_NAME="radeonsi"
            export VDPAU_DRIVER="radeonsi"
          elif command -v lspci >/dev/null 2>&1 && lspci | grep -iE 'vga.*intel' >/dev/null; then
            # Intel
            export LIBVA_DRIVER_NAME="iHD"
          fi
          EOF
          chmod +x $HOME/.local/scripts/x11-vars.sh
        '');

        # Source the script in .profile (shell-agnostic, covers bash/zsh/fish/etc.)
        file = {
          ".profile".text = mkIf (!isNixOS) ''
            [ -f "$HOME/.local/scripts/x11-vars.sh" ] && . "$HOME/.local/scripts/x11-vars.sh"
          '';
        };
      };
    };

    # gnome.gnome-keyring was removed/changed in home-manager 25.05, so disable it
    # services = {
    #   gnome.gnome-keyring = mkIf ((desktop != "kde" && desktop != "pantheon") && isNixOS) {
    #     enable = true;
    #   };
    # };
  };
}
