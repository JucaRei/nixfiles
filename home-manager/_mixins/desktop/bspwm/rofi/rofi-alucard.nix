{ pkgs, username, ... }: {

  programs = {
    rofi = {
      enable = true;
      plugins = [ pkgs.rofi-calc ];
      # terminal = "\${pkgs.kitty}/bin/kitty";
    };
  };
  xdg = {
    configFile = {
      "rofi".source = "./rofi-alucard";
      recursive = true;
    };
  };
}
