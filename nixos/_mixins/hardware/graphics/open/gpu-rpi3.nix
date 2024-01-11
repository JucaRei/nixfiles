{ config, pkgs, ... }:

{
  config = {
    hardware.opengl = {
      enable = true;
      setLdLibraryPath = true;
      package = pkgs.mesa_drivers;
    };
    # hardware.raspberry-pi."3".fkms-3d.enable = true;

    system.build = {
      visualizer2Pkg = pkgs.visualizer2;
      mesaPkg = pkgs.mesa;
    };

    nixpkgs.overlays = [
      (final: prev: {
        mesa = (prev.mesa.override {
          eglPlatforms = [
            "x11"
            "wayland"
          ];
          galliumDrivers = [
            "swrast"
            "virgl"
            "kmsro" # cargo culted?
            "vc4" # rpi
            "v3d"
            "zink"
          ];
          vulkanDrivers = [
            "swrast"
            "broadcom"
          ];
          vulkanLayers = [
            "device-select"
          ];
        });
      })
    ];
    environment.systemPackages = with pkgs; [
      libva-utils
      vulkan-tools
      vulkan-loader
      vulkan-headers
      glxinfo
      glmark2
    ];
  };
}
