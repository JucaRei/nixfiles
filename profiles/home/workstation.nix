{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
  pt = "pt_BR.UTF-8";
  en = "en_US.UTF-8";
in
{
  config = {
    desktop = {
      modifierKey = mkDefault "Alt";

      theme = {
        enable = mkDefault true;
        name = mkDefault "catppuccin-macchiato";
        accent = mkDefault "red";
      };

      wallpaper = {
        enable = mkDefault true;
        directory = mkDefault "${config.home.homeDirectory}/Pictures/Wallpapers";
        randomOnStart = mkDefault true;
        interval = mkDefault "5m";
      };

      touchpad = {
        enable = mkDefault true;
        speed = mkDefault 0.5;
        naturalScrolling = mkDefault true;
        tapping = mkDefault true;
      };

      bspwm = {
        polybar = {
          battery = mkDefault "BAT1";
          adapter = mkDefault "ACAD";
          style = mkDefault "pills";
          encapsulation = {
            workspaces = {
              style = mkDefault "powerline";
              accent = mkDefault "#ff5555";
            };
            stats = {
              style = mkDefault "shapes";
            };
            netspeed = {
              style = mkDefault "slant";
              color = mkDefault "#29339B";
              accent = mkDefault "#8be9fd";
            };
          };
        };
      };
    };

    system = {
      programs = {
        console = {
          bat.enable = mkDefault true;
          eza.enable = mkDefault true;
        };

        browsers = {
          firefox = {
            enable = mkDefault true;
            version = mkDefault "librewolf";
          };
        };

        documents = {
          zathura.enable = mkDefault true;
        };

        editors = {
          antigravity.enable = mkDefault true;
        };

        file-manager = {
          thunar.enable = mkDefault true;
        };

        terminal = {
          enable = mkDefault true;
          name = mkDefault "alacritty";
        };

        multimedia = {
          mpv = {
            enable = mkDefault true;
            installPackage = mkDefault true;
            floating = mkDefault false;
          };
        };

        tools = {
          yt-dlp.enable = mkDefault true;
          fastfetch.enable = mkDefault true;
        };

        shells = {
          default = mkDefault "zsh";
        };
      };

      services = {
        fcitx5.enable = mkDefault true;
      };
    };

    programs = {
      antigravity-cli.enable = mkDefault false;
    };

    home = {
      packages = [
        pkgs.nerd-fonts.lilex
        pkgs.git
        pkgs.duf
        pkgs.ripgrep
        pkgs.htop
      ];

      sessionVariables = {
        TZ = mkDefault "America/Sao_Paulo";
        TZDIR = mkDefault "${pkgs.tzdata}/share/zoneinfo";
      };

      language = {
        base = mkDefault en;
        messages = mkDefault en;
        ctype = mkDefault pt;
        time = mkDefault pt;
        numeric = mkDefault pt;
        monetary = mkDefault pt;
        paper = mkDefault pt;
        name = mkDefault pt;
        address = mkDefault pt;
        telephone = mkDefault pt;
        measurement = mkDefault pt;
      };

      keyboard = {
        layout = mkDefault "us,br";
        variant = mkDefault "intl,abnt2";
        model = mkDefault "pc105";
        options = mkDefault [ "grp:caps_toggle" ];
      };
    };
  };
}
