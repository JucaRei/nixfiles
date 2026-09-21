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
      }
      // lib.optionalAttrs isNixOS {
        LIBVA_DRIVER_NAME =
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
            (osConfig.environment.sessionVariables.LIBVA_DRIVER_NAME or "");

        VDPAU_DRIVER =
          if hasLegacyNvidia then
            "nvidia"
          else if hasNvidia || hasGpuFallback == "nvidia" then
            "nvidia"
          else if hasAmd || hasGpuFallback == "amd" then
            "radeonsi"
          else if hasArmGpu || hasGpuFallback == "arm" then
            "v3d"
          else
            (osConfig.environment.sessionVariables.VDPAU_DRIVER or "");
      }
      // lib.optionalAttrs (isNixOS && (hasLegacyNvidia || (osConfig.environment.sessionVariables ? LD_LIBRARY_PATH))) {
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
          elif command -v lspci >/dev/null 2>&1 && lspci | grep -iE 'vga.*intel' >/dev/null; then
            if lspci | grep -iE '2nd Generation|3rd Gen|4th Gen|HD Graphics 3000|HD Graphics 4000|HD Graphics 2500|HD Graphics 2000' >/dev/null; then
              export LIBVA_DRIVER_NAME="i965"
            else
              export LIBVA_DRIVER_NAME="iHD"
            fi
            export LIBVA_DRIVERS_PATH="${pkgs.intel-media-driver}/lib/dri:${pkgs.intel-vaapi-driver}/lib/dri:/usr/lib/x86_64-linux-gnu/dri:/usr/lib/dri"
          elif command -v lspci >/dev/null 2>&1 && lspci | grep -iE 'vga.*amd|radeon' >/dev/null; then
            export LIBVA_DRIVER_NAME="radeonsi"
            export VDPAU_DRIVER="radeonsi"
            export LIBVA_DRIVERS_PATH="${pkgs.mesa}/lib/dri:/usr/lib/x86_64-linux-gnu/dri:/usr/lib/dri"
          elif command -v lspci >/dev/null 2>&1 && lspci | grep -iE 'vga.*nvidia' >/dev/null; then
            export LIBVA_DRIVER_NAME="nvidia"
            export VDPAU_DRIVER="nvidia"
            export __GLX_VENDOR_LIBRARY_NAME="nvidia"
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
