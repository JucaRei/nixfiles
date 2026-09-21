{ pkgs, ... }:
{
  config = {
    desktop = {
      monitors = [
        {
          name = "HDMI-1-0";
          width = 1920;
          height = 1080;
          refresh = 60;
          x = 0;
          y = 0;
          primary = false;
        }
        {
          name = "HDMI-1-1";
          width = 1920;
          height = 1080;
          refresh = 60;
          x = 0;
          y = 0;
          primary = false;
        }
        {
          name = "eDP-1";
          width = 1920;
          height = 1080;
          refresh = 60;
          x = 1920;
          y = 0;
          primary = true;
        }
      ];
    };

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
          antigravity.enable = true;
        };
        terminal = {
          enable = true;
          name = "alacritty";
        };
      };
    };

    home = {
      packages = with pkgs; [
        git
        xfce4-terminal
        duf
        fzf
        ripgrep
        htop
        btop
      ];

      sessionPath = [
        "/usr/sbin"
        "/sbin"
      ];

      sessionVariables = {
        NIX_REMOTE = "daemon";
        LC_ALL = "";
      };

      language = {
        base = "en_US.UTF-8";
        messages = "en_US.UTF-8";
        ctype = "pt_BR.UTF-8";
        time = "pt_BR.UTF-8";
        numeric = "pt_BR.UTF-8";
        monetary = "pt_BR.UTF-8";
        paper = "pt_BR.UTF-8";
        name = "pt_BR.UTF-8";
        address = "pt_BR.UTF-8";
        telephone = "pt_BR.UTF-8";
        measurement = "pt_BR.UTF-8";
      };
    };

    programs = {
      antigravity-cli.enable = true;
    };
  };
}
