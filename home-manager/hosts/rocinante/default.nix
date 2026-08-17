{ config, pkgs, ... }:
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
