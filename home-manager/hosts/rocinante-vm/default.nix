{
  config,
  lib,
  pkgs,
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

    # Desativa compositor picom para zerar o overhead de CPU em renderização por software (Celeron N4000)
    desktop.bspwm.picom.enable = false;

    # Adiciona a extensão Continue (Chat + Autocomplete com Gemini) no VS Code da VM
    programs.vscode.profiles.default.extensions =
      lib.mkIf config.system.programs.editors.vscode.enable (
        pkgs.nix4vscode.forVscode [
          "Continue.continue"
        ]
      );

    home.packages = with pkgs; [
      direnv
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
