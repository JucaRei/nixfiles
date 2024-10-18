_: {
  imports = [
    ./boot.nix
    ./cpu.nix
    ./documentation.nix
    ./network.nix
    ./optimizations.nix
    ./locales.nix
    ./scripts.nix
    ./security.nix
  ];
  boot = {
    kernel.sysctl = {
      "vm.dirty_ratio" = 6; # sync disk when buffer reach 6% of memory
    };
  };
}
