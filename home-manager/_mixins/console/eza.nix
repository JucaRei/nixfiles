{ inputs, platform, ... }: {
  home = {
    packages = with inputs; [
      fh.packages.${platform}.default
      eza.packages.${platform}.default
    ];
    shellAliases = {
      l = "eza -lah";
      la = "eza -a";
      ll = "eza -l";
      lla = "eza -la";
      ls = "eza";
      tree = "eza --tree";
    };
  };
}
