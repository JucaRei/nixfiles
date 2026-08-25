{
  config,
  lib,
  pkgs,
  desktop,
  ...
}:
let
  inherit (lib) mkIf mkForce;
  graphics = config.hardware.graphics.cards;
  backend = config.desktop.display-servers.backend;

  nvidia-card = "$(${pkgs.uutils-coreutils-noprefix}/bin/readlink -f /dev/dri/by-path/pci-0000:01:00.0-card)";

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
      sessionVariables = {
        __EGL_VENDOR_LIBRARY_FILENAMES =
          (mkIf (graphics.gpu == "hybrid-nvidia"))
            "${config.hardware.nvidia.package}/share/glvnd/egl_vendor.d/10_nvidia.json:${config.hardware.graphics.package}/share/glvnd/egl_vendor.d/50_mesa.json";
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
