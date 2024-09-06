{ config, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  config = {
    features = {
      mime.defaultApps = mkDefault {
        enable = true;
        # defaultBrowser = "floorp.desktop";
        defaultFileManager = "nemo.desktop";
        defaultAudioPlayer = "io.bassi.Amberol.desktop";
        # defaultVideoPlayer = "mpv.desktop";
        # defaultPdf = "org.pwmt.zathura.desktop";
        defaultPlainText = "org.gnome.gedit.desktop";
        defaultImgViewer = "xviewer.desktop";
        defaultArchiver = "org.gnome.FileRoller.desktop";
        defaultExcel = "calc.desktop";
        defaultWord = "writer.desktop";
        defaultPowerPoint = "impress.desktop";
        defaultEmail = "org.gnome.Geary.desktop";
      };
    };
  };
}
