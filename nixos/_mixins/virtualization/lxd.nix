_: {
  virtualisation = {
    lxd = {
      enable = true;
      recommendedSysctlSettings = true;
      #zfsSupport = true;
      # lxcPackage = pkgs.lxc; # required for AppArmor profiles)
    };
  };
}
