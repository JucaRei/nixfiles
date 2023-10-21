{ pkgs, ... }: {

  programs = {
    rofi = {
      enable = true;
    };
    plugins = [ pkgs.rofi-calc ];
    terminal = "\${pkgs.kitty}/bin/kitty";
  };
  xdg = {
    configFile = {
      "rofi/colors.rasi" = {
        text = builtins.readFile ./colors.rasi;
      };
      "rofi/confirm.rasi" = {
        text = builtins.readFile ./confirm.rasi;
      };
      "rofi/launcher.rasi" = {
        text = builtins.readFile ./launcher.rasi;
      };
      "rofi/message.rasi" = {
        text = builtins.readFile ./message.rasi;
      };
      "rofi/networkmenu.rasi" = {
        text = builtins.readFile ./networkmenu.rasi;
      };
      "rofi/powermenu.rasi" = {
        text = builtins.readFile ./powermenu.rasi;
      };
      "rofi/styles.rasi" = {
        text = builtins.readFile ./styles.rasi;
      };
      "rofi/bin/launcher.sh" = {
        executable = true;
        text = ''
          #!/bin/sh

          rofi -no-config -no-lazy-grab -show drun -modi drun -theme ~/.config/rofi/launcher.rasi
        '';
      };
    };
  };
}
