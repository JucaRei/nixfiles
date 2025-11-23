{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.display-managers.regreet;
in
{
  options = {
    desktop.display-managers.regreet = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable's regreet as display manager.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.greetd.regreet}/bin/regreet --style /etc/greetd/regreet-custom.css";
        user = "greeter";
      };
    };
    programs.regreet = {
      enable = true;
      settings = {
        background = {
          path = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
          fit = "Cover";
        };
        GTK = {
          application_prefer_dark_theme = true;
          theme_name = "Dracula";
          cursor_theme_name = "Dracula-cursors";
          cursor_theme_size = 16;
          icon_theme_name = lib.mkDefault "Yaru-magenta-dark";
          font_name = "Sans 12";
        };
      };
    };
    environment = {
      etc."greetd/regreet-custom.css".text = ''
        window{background-color:rgba(0,0,0,0.8);}
        entry{border-radius:5px;padding:10px;}
        button{background-color:#cba6f7;transition:background-color 0.3s ease;}
        button:hover{background-color:#94e2d5;}
      '';
      systemPackages = with pkgs; [ dracula-theme yaru-theme ];
    };
  };
}
