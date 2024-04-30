# Brave on XWayland, because of Nvidia
{ pkgs, ... }: {
  wrappers.bravex = {
    basePackage = pkgs.unstable.brave;
    flags = [
      "--force-dark-mode"
      "--enable-features=VaapiVideoEncoder,VaapiVideoDecoder,CanvasOopRasterization,TouchpadOverscrollHistoryNavigation,WebUIDarkMode"
      "--enable-zero-copy"
      "--use-gl=desktop"
      "--ignore-gpu-blocklist"
      "--enable-oop-rasterization"
      "--enable-gpu-compositing"
      "--enable-gpu-rasterization"
      "--enable-native-gpu-memory-buffers"
      "--use-vulkan"
      "--disable-features=UseChromeOSDirectVideoDecoder"
      "--enable-features=WebUIDarkMode"
      "--no-default-browser-check"
    ];
    # extraWrapperFlags = "--unset WAYLAND_DISPLAY --unset NIXOS_OZONE_WL";
  };
}
