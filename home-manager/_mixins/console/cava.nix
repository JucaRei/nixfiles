{pkgs, ...}: let
  inherit (pkgs.stdenv) isLinux;
in {
  programs = {
    cava = {
      enable = isLinux;
      settings = {
        color = {
          gradient = 1;
          gradient_count = 8;
          gradient_color_1 = "'#59cc33'";
          gradient_color_2 = "'#80cc33'";
          gradient_color_3 = "'#a6cc33'";
          gradient_color_4 = "'#cccc33'";
          gradient_color_5 = "'#cca633'";
          gradient_color_6 = "'#cc8033'";
          gradient_color_7 = "'#cc5933'";
          gradient_color_8 = "'#cc3333'";
        };
      };
    };
  };
}
