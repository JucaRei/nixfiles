{ pkgs, ... }: {
  home = {
    packages = with pkgs; [ exa ];
    # shellAliases = {
    #   ls = "exa --icons -l -T -L=1";
    #   # ls = "exa --icons -Slhga";
    #   l = "exa --icons -l --time-style long-iso -a -h";
    #   la = "exa --icons -l --time-style long-iso -a";
    #   ll = "exa --icons -l";
    #   lla = "exa --icons -la";
    #   tree = "exa --icons --tree -l";
    # };
  };
  programs = {
    exa = {
      enable = true;
      enableAliases = true;
      extraOptions = [
        "--group-directories-first"
        "--color=always"
        "--header"
      ];
      git = true;
      icons = true;
    };
  };
}
