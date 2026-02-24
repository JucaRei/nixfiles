{ lib, config, pkgs, desktop, osConfig ? null, platform, ... }:

let
  inherit (lib) mkIf concatLists;
  backend = config.desktop.display-servers.backend;
  isNixOS = osConfig != null;
  isArm = platform == "aarch64-linux" || platform == "armv7l-linux";

  videoDrivers = if isNixOS then (osConfig.services.xserver.videoDrivers or [ ]) else [ ];
  hasNvidia = lib.elem "nvidia" videoDrivers;
  hasIntel = lib.elem "intel" videoDrivers;
  hasAmd = lib.any (d: d == "amdgpu" || d == "radeon" || d == "ati") videoDrivers;
  hasArmGpu = isArm && lib.any (d: d == "vc4" || d == "panfrost" || d == "rockchip" || d == "kmsro") videoDrivers;
in

{
  config = mkIf (backend == "x11") {
    home = {
      # ── FIXED: home.packages must always be a list ─────────────────────
      packages = with pkgs; concatLists [
        (mkIf (desktop == "bspwm") [
          wmctrl
          notify-desktop
          xdotool
          ydotool
        ])
        (mkIf (!isNixOS) [
          pciutils
          glxinfo
        ])
      ];

      sessionVariables = {
        _JAVA_AWT_WM_NONREPARENTING = mkIf (desktop == "bspwm") "1";

        LIBVA_DRIVER_NAME = mkIf isNixOS (
          if hasNvidia then "nvidia" else
          if hasAmd then "radeonsi" else
          if hasIntel then "iHD" else
          if hasArmGpu then "v3d" else null
        );

        VDPAU_DRIVER = mkIf isNixOS (
          if hasNvidia then "nvidia" else
          if hasAmd then "radeonsi" else
          if hasArmGpu then "v3d" else null
        );
      };

      # your activation.setX11Vars and file.".profile" blocks stay exactly the same
      activation.setX11Vars = mkIf (!isNixOS) (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -pv $HOME/.local/scripts
        cat > $HOME/.local/scripts/x11-vars.sh <<EOF
        #!/bin/sh
        if [ -f /proc/device-tree/model ] && grep -iqE 'raspberry|nanopi|rockchip' /proc/device-tree/model; then
          export LIBVA_DRIVER_NAME="v3d"
          export VDPAU_DRIVER="v3d"
        elif command -v lspci >/dev/null 2>&1 && lspci | grep -iE 'vga.*nvidia' >/dev/null; then
          export LIBVA_DRIVER_NAME="nvidia"
          export VDPAU_DRIVER="nvidia"
          export __GLX_VENDOR_LIBRARY_NAME="nvidia"
        elif command -v lspci >/dev/null 2>&1 && lspci | grep -iE 'vga.*amd|radeon' >/dev/null; then
          export LIBVA_DRIVER_NAME="radeonsi"
          export VDPAU_DRIVER="radeonsi"
        elif command -v lspci >/dev/null 2>&1 && lspci | grep -iE 'vga.*intel' >/dev/null; then
          export LIBVA_DRIVER_NAME="iHD"
        fi
        EOF
        chmod +x $HOME/.local/scripts/x11-vars.sh
      '');

      file = {
        ".profile".text = mkIf (!isNixOS) ''
          [ -f "$HOME/.local/scripts/x11-vars.sh" ] && . "$HOME/.local/scripts/x11-vars.sh"
        '';
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
