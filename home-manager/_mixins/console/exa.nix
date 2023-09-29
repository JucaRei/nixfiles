{ pkgs, ... }: {
  home = {
    packages = with pkgs; [ exa ];
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
