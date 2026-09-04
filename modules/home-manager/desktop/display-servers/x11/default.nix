{
  lib,
  config,
  pkgs,
  desktop,
  osConfig ? null,
  platform,
  ...
}:
let
  inherit (lib) mkIf optionals;

  backend = config.desktop.display-servers.backend;
  isNixOS = osConfig != null;
  isArm = platform == "aarch64-linux" || platform == "armv7l-linux";

  videoDrivers = if isNixOS then (osConfig.services.xserver.videoDrivers or [ ]) else [ ];
  hasNvidia = lib.elem "nvidia" videoDrivers;
  hasIntel = lib.elem "intel" videoDrivers;
  hasAmd = builtins.any (x: lib.elem x videoDrivers) [
    "amdgpu"
    "radeon"
    "ati"
  ];
  hasArmGpu =
    if isArm then
      (builtins.any (x: lib.elem x videoDrivers) [
        "vc4"
        "panfrost"
        "rockchip"
        "kmsro"
      ])
    else
      false;

  hasGpuFallback =
    if videoDrivers != [ ] && isNixOS then
      if hasNvidia then
        "nvidia"
      else if hasAmd then
        "amd"
      else if hasIntel then
        "intel"
      else if hasArmGpu then
        "arm"
      else
        null
    else
      null;
  hasLegacyNvidia = isNixOS && ((osConfig.hardware.graphics.cards.gpu or null) == "nvidia-legacy");
in
{
  config = mkIf (backend == "x11") {
    home = {
      packages =
        with pkgs;
        optionals (desktop == "bspwm") [
          notify-desktop
          ydotool
        ]
        ++ optionals (!isNixOS) [
          pciutils
          virtualgl
        ];

      sessionVariables = {
        # Java fix for non-reparenting WMs (bspwm, etc.)
        "_JAVA_AWT_WM_NONREPARENTING" = lib.mkDefault (if desktop == "bspwm" then "1" else "");

        # Hardware acceleration (declarative on NixOS)
        LIBVA_DRIVER_NAME =
          if isNixOS then
            (
              if hasLegacyNvidia then
                "vdpau"
              else if hasIntel || hasGpuFallback == "intel" then
                "iHD"
              else if hasNvidia || hasGpuFallback == "nvidia" then
                "nvidia"
              else if hasAmd || hasGpuFallback == "amd" then
                "radeonsi"
              else if hasArmGpu || hasGpuFallback == "arm" then
                "v3d"
              else
                (osConfig.environment.sessionVariables.LIBVA_DRIVER_NAME or "")
            )
          else
            "";

        VDPAU_DRIVER =
          if isNixOS then
            (
              if hasLegacyNvidia then
                "nvidia"
              else if hasNvidia || hasGpuFallback == "nvidia" then
                "nvidia"
              else if hasAmd || hasGpuFallback == "amd" then
                "radeonsi"
              else if hasArmGpu || hasGpuFallback == "arm" then
                "v3d"
              else
                (osConfig.environment.sessionVariables.VDPAU_DRIVER or "")
            )
          else
            "";
      } // lib.optionalAttrs (isNixOS && (hasLegacyNvidia || (osConfig.environment.sessionVariables ? LD_LIBRARY_PATH))) {
        LD_LIBRARY_PATH =
          if hasLegacyNvidia then
            "/run/opengl-driver/lib:/run/opengl-driver-32/lib"
          else
            osConfig.environment.sessionVariables.LD_LIBRARY_PATH;
      };

      activation.setX11Vars = mkIf (!isNixOS) (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
        ''
      );

      file = {
        ".profile".text = mkIf (!isNixOS) ''
          [ -f "$HOME/.local/scripts/x11-vars.sh" ] && . "$HOME/.local/scripts/x11-vars.sh"
        '';
      };
    };
  };
}
