{
  lib,
  pkgs,
  desktop ? null,
  ...
}:
{
  config = {
    system = {
      programs = {
        console = {
          bat.enable = true;
          eza.enable = true;
        };
        browsers = {
          firefox.enable = true;
        };
        editors = {
          vscode = {
            enable = true;
            enableConfigurableSettings = true;
          };
        };
        terminal = {
          enable = true;
          name = "alacritty";
        };
      };
    };

    # Mapeamento do Teclado Apple (Command = Super / Mod4, Option = Alt / Mod1)
    home.keyboard = {
      options = [
        "altwin:swap_alt_win"
      ];
    };

    desktop.bspwm = lib.mkIf (desktop == "bspwm") {
      extraConfig = ''
        # Garante no BSPWM que a tecla Command funcione como Super (Mod4)
        ${pkgs.setxkbmap}/bin/setxkbmap -option altwin:swap_alt_win
      '';
    };

    home.packages = with pkgs; [
      brightnessctl
      pamixer
      pavucontrol
      eza
      bat
      duf
      fzf
      ripgrep
      htop
      btop
    ];
  };
}
