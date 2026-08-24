{ pkgs, ... }:
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

    # Teclado Apple: swap_opt_cmd=0 no kernel já define Command = Super (Mod4) e Option = Alt (Mod1) nativamente

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
