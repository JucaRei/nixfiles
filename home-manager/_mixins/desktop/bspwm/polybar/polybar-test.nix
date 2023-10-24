{ pkgs, ... }: {
  services = {
    polybar = {
      enable = true;
      package = pkgs.polybarFull;
      settings = "";
      config = ../test/polybar/config.ini;
    };
  };
  xdg = {
    configFile."polybar/bin".source = builtins.path {
      path = ../test/polybar/scripts;
      executable = true;
      # name = "";
    };
  };
}
