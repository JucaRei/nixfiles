let
  # GTX 1050
  gpuIDs = [
    "10de:1c8d" # Graphics
    "10de:0fb9" # Audio
  ];
in
{ pkgs, lib, config, ... }: {
  options.vfio.enable = with lib; mkOption {
    description = "Whether to enable VFIO";
    type = types.bool;
    default = true;
  };

  config =
    let cfg = config.vfio;
    in {
      boot = {
        loader.grub.configurationName = lib.mkForce "Pass-through Nvidia";
        initrd.kernelModules = [
          "vfio_pci"
          "vfio"
          "vfio_iommu_type1"
          # "vfio_virqfd" ## already in path since kernel 6.2

          "clearcpuid=514" # Fixes certain wine games crash on launch
          "nvidia"
          "nvidia_modeset"
          "nvidia_uvm"
          "nvidia_drm"
        ];

        kernelParams = [
          # enable IOMMU
          "intel_iommu=on"
          "iommu=pt"
          # "amd_iommu=on"
        ] ++ lib.optional cfg.enable
          # isolate the GPU
          ("vfio-pci.ids=" + lib.concatStringsSep "," gpuIDs);
      };
    };
}
