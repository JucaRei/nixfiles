{ pkgs, ... }: {
  programs = {
    eza = {
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
