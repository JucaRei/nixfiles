{ config, pkgs, ... }: {
  home = {
    file = {
      "${config.xdg.configHome}/sakura/sakura.conf".text =
        builtins.readFile ../../config/sakura/sakura.conf;
    };
    packages = with pkgs; [ sakura ];
  };
}
