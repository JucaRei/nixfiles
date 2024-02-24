{ pkgs, ... }:
let
  thunar-with-plugins = with pkgs.xfce;
    (thunar.override {
      thunarPlugins =
        [ thunar-volman thunar-archive-plugin thunar-media-tags-plugin ];
    });
in {
  home = {
    packages = with pkgs.xfce;
      [
        exo
        thunar-with-plugins
        tumbler # file thumbnails
        catfish # search tool
      ] ++ (with pkgs; [
        mate.engrampa # archiver
        zip
        unzip
        libgsf
        ffmpegthumbnailer
      ]);
  };
  xfconf.settings = {
    thunar = {
      "default-view" = "ThunarDetailsView";
      "misc-middle-click-in-tab" = true;
      "misc-open-new-window-as-tab" = true;
      "misc-single-click" = false;
      "misc-volume-management" = false;
    };
  };
}
