{ nixos-hardware }: { ... }: {
  imports = [
    (nixos-hardware.outPath + "/common/pc/laptop")
    (nixos-hardware.outPath + "/common/gpu/intel")
  ];
}
