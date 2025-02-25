{ pkgs, lib, config, ... }:
let
  inherit (lib) mkDefault;
in
{
  config = {
    features.mime.defaultApps = mkDefault {
      enable = true;
      defaultBrowser = "firefox.desktop";
      defaultFileManager = "thunar.desktop";
      defaultAudioPlayer = "rhythmbox.desktop";
      defaultVideoPlayer = "mpv.desktop";
      defaultPdf = "atril.desktop";
      defaultPlainText = "org.xfce.mousepad.desktop";
      defaultImgViewer = "org.xfce.ristretto.desktop";
      defaultArchiver = "engrampa.desktop";
      defaultExcel = "calc.desktop";
      defaultWord = "writer.desktop";
      defaultPowerPoint = "impress.desktop";
      defaultEmail = "org.gnome.Geary.desktop";
    };

    desktop.apps = {
      file-managers = {
        thunar.enable = true;
      };
      audio = {
        rhythmbox.enable = true;
      };
    };

    home = {
      packages = with pkgs // pkgs.xfce // pkgs // pkgs.mate // pkgs.xorg; [
        elementary-xfce-icon-theme
        gnome-keyring
        gparted
        galculator
        orage

        # (writeShellApplication {
        #   name = "xfce4-panel-toggle";
        #   runtimeInputs = [ xfce.xfconf ];
        #   text = ''
        #     for num in {0,1}
        #     do
        #       current=$(xfconf-query -c xfce4-panel -p /panels/panel-"$num"/autohide-behavior)
        #       if [[ current -eq 1 ]]; then next=0; else next=1; fi
        #       xfconf-query -c xfce4-panel -p /panels/panel-"$num"/autohide-behavior -s $next
        #     done
        #   '';
        # })
      ];

      file = {
        "${config.xdg.dataHome}/xfce4/terminal/colorschemes/Dracula.theme".text =
          lib.fileContents ../../../../resources/hm-configs/desktop/xfce/terminal/Dracula.theme;
      };
    };
  };
}
