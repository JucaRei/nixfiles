{ pkgs, ... }: {
  imports = [
    ../default/polybar/scripts.nix
  ];
  services = {
    polybar = {
      enable = true;
      package = pkgs.polybar;
      script = "";
    };
  };
  xdg = {
    configFile = {
      "polybar".source = builtins.path {
        path = ../../../config/polybar-everforest;
      };
    };
  };
}
