{ pkgs, ... }: {

  programs = {
    rofi = {
      enable = true;
      plugins = [ pkgs.rofi-calc ];
    };
  };

  home = {
    file = {
      # ".config/polybar".source = builtins.path {
      #   path = ../../../../config/polybar-everforest;
      # };
      ".config/rofi" = {
        source = ../../../../config/rofi-everforest;
        recursive = true;
      };
      ".local/rofi" = {
        source = ../../../../config/rofi-scripts;
        recursive = true;
        executable = true;
      };
    };
  };
}
