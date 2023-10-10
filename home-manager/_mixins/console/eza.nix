{ inputs, platform, ... }: {
  home = {
    packages = with inputs; [
      fh.packages.${platform}.default
      eza.packages.${platform}.default
    ];
    shellAliases = {
      l = "eza --icons -l --time-style long-iso -a -h";
      la = "eza --icons -l --time-style long-iso -a";
      ll = "eza --icons -l";
      lla = "eza --icons -la";
      ls = "eza --icons";
      tree = "eza --icons --tree -l";
    };
  };
}
