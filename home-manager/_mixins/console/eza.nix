{ inputs, platform, ... }: {
  home = {
    packages = with inputs; [
      fh.packages.${platform}.default
      eza.packages.${platform}.default
    ];
    shellAliases = {
      ls = "eza --icons -l -T -L=1";
      # ls = "eza --icons -Slhga";
      l = "eza --icons -l --time-style long-iso -a -h";
      la = "eza --icons -l --time-style long-iso -a";
      ll = "eza --icons -l";
      lla = "eza --icons -la";
      tree = "eza --icons --tree -l";
    };
  };
}
