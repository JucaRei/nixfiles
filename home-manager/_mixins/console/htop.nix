{ pkgs, config, ... }: {
  home = {
    packages = [ pkgs.htop ];
    file = {
      "${config.xdg.configHome}/htop/htoprc".text = builtins.readFile ../config/htop/htoprc;
    };
  };
}
