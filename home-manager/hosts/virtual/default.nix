{
  pkgs,
  config,
  lib,
  nixGLWrapper ? lib.id,
  ...
}:
let
  fhd = {
    width = 1920;
    height = 1080;
    refresh = 60;
  };
  pt = "pt_BR.UTF-8";
  en = "en_US.UTF-8";
in
{
  config = {
    desktop = {
      monitors = [
        (
          fhd
          // {
            name = "Virtual-1";
            x = 0;
            y = 0;
            primary = true;
          }
        )
      ];

      modifierKey = "Alt";

      theme = {
        enable = true;
        name = "catppuccin-macchiato"; # "doom" #"tokyo-night"
        accent = "red";
      };

      wallpaper = {
        enable = true;
        directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
        randomOnStart = true;
        interval = "5m";
      };

      touchpad = {
        enable = true;
        speed = 0.5; # Velocidade aumentada (0.0 padrão -> 0.5 ágil e preciso para Full HD)
        naturalScrolling = true;
        tapping = true;
      };

      bspwm = {
        polybar = {
          battery = "BAT1";
          adapter = "ACAD";
          style = lib.mkDefault "pills";
          encapsulation = {
            workspaces = {
              style = "powerline";
              # color = "#22202070";
              accent = "#ff5555";
            };
            stats = {
              style = "shapes";
              # accent = "coral";
              # color = "#2c2c35b7";  # cor de fundo da cápsula
            };
            netspeed = {
              style = "slant";
              color = "#29339B"; # cor de fundo da cápsula
              accent = "#8be9fd"; # texto de velocidade em destaque
            };
          };
        };

        extraKeybindings = {
          "ctrl + shift + t" = "bspc node -t '~floating'";
        };
      };

    };

    system = {
      programs = {
        console = {
          bat.enable = true;
          eza.enable = true;
        };

        browsers = {
          firefox = {
            enable = true;
            version = "librewolf";
          };
        };

        documents = {
          zathura.enable = true;
        };

        editors = {
          antigravity.enable = true;
        };

        file-manager = {
          thunar.enable = true;
        };

        terminal = {
          enable = true;
          name = "alacritty";
        };

        multimedia = {
          mpv = {
            enable = true;
            hybridGraphics = false;
            installPackage = true;
            floating = false;
          };
        };

        tools = {
          yt-dlp = {
            enable = true;
          };

          fastfetch = {
            enable = true;
          };
        };

        shells = {
          default = "zsh";
        };

      };

      services = {
        fcitx5.enable = true;
        flatpak = {
          enable = true;
          packages = [ ];
        };
      };
    };

    home = {
      packages = with pkgs; [
        nerd-fonts.lilex
        git
        duf
        ripgrep
        htop

        (nixGLWrapper mdhero)
      ];

      shellAliases = {
        # vainfo = "vainfo-intel";
      };

      sessionPath = [
        "/usr/sbin"
        "/sbin"
      ];

      sessionVariables = {
        NIX_REMOTE = "daemon";
        LC_ALL = "";
        TZ = "America/Sao_Paulo";
        TZDIR = "${pkgs.tzdata}/share/zoneinfo";
      };

      language = {
        base = en;
        messages = en;
        ctype = pt;
        time = pt;
        numeric = pt;
        monetary = pt;
        paper = pt;
        name = pt;
        address = pt;
        telephone = pt;
        measurement = pt;
      };

      # Teclado com layouts US Internacional e ABNT2 (alternância via Caps Lock ou Polybar)
      keyboard = {
        layout = "us,br";
        variant = "intl,abnt2";
        model = "pc105";
        options = [ "grp:caps_toggle" ];
      };
    };

    programs = {
      # antigravity-cli.enable = true;
      # claude-code.enable = true;
    };
    # Exibição personalizada do teclado na Polybar para o host Virtual
    services.polybar.config."module/keyboard" = {
      layout-icon-0 = "us;INTL";
      layout-icon-1 = "br;ABNT2";
      label-layout = "%icon%";
    };

  };
}
