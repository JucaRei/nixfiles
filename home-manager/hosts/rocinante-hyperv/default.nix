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

    # Configuração do Picom 100% estável e otimizada para o Framebuffer do Hyper-V
    services.picom = {
      enable = true;
      backend = "xrender"; # Essencial no Hyper-V: evita travamento de GLX/OpenGL no framebuffer virtual
      vSync = false; # Essencial no Hyper-V: vSync=true congela o X11 pois o Hyper-V não envia VSync interrupts
      shadow = false; # Desativa sombras em software para resposta instantânea
      fade = false; # Sem delay/engasgo de animações de transição de janela
      settings = {
        corner-radius = 0;
        use-damage = false; # Evita flickering/artefatos no display do Hyper-V
      };
    };

    # Adiciona a extensão Continue (Chat + Autocomplete com Gemini) no VS Code do Hyper-V
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
