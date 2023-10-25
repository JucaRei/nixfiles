{ pkgs, username, ... }: {

  programs = {
    rofi = {
      enable = true;
      plugins = [ pkgs.rofi-calc ];
      # terminal = "\${pkgs.kitty}/bin/kitty";
    };
  };
  xdg = {
    configFile."rofi".source = builtins.path {
      path = ./alucard;
      # name = "";
    };
  };

  # home.file.".vim".source = builtins.path {
  #   path = ./config;
  #   name = "vim-config";
  # };
}
