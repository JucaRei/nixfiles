{ pkgs, ... }: {
  home = {
    packages = [ pkgs.libnotify ]; # Depency
    services = {
      dunst = {
        enable = true;
        iconTheme = {
          name = "Papirus Dark";
          package = pkgs.papirus-icon-theme;
          size = "16x16";
        };
        settings = {
          global = {
            monitor = 0;
            width = 300;
            height = 200;
            origin = "top-right";
            offset = "50x50";
            shrink = "yes";
            transparency = 10;
            padding = 10;
            
          };
        };
      };
    };
  };
}
