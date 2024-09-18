{ config, lib, pkgs, desktop, ... }:
let
  cfg = config.custom.features.mime.defaultApps;
  inherit (lib) types mkEnableOption mkOption mdDoc mkIf optionals;
in
{
  options = {
    custom.features.mime.defaultApps = {
      enable = mkEnableOption (mdDoc "Enable default mime for selected SYSTEM.") // { default = true; };
      defaultBrowser = mkOption {
        type = types.nullOr types.str;
        description = mdDoc ''
          Desktop file for the browser. It should support browser protocols.
        '';
        default = null;
      };
      defaultFileManager = mkOption {
        type = types.nullOr types.str;
        description = mdDoc ''
          Desktop file for the default file manager of the system.
        '';
        default = null;
      };
      defaultEmail = mkOption {
        type = types.nullOr types.str;
        description = mdDoc ''
          Desktop file for the default file manager of the system.
        '';
        default = null;
      };
      defaultAudioPlayer = mkOption {
        type = types.nullOr types.str;
        description = mdDoc ''
          Desktop file for the browser. It should support videos files
        '';
        default = null;
      };
      defaultVideoPlayer = mkOption {
        type = types.nullOr types.str;
        description = mdDoc ''
          Desktop file for the browser. It should support videos files
        '';
        default = null;
      };
      defaultPdf = mkOption {
        type = types.nullOr types.str;
        description = mdDoc ''
          Desktop file for the browser. It should support pdf archives.
        '';
        default = null;
      };
      defaultPlainText = mkOption {
        type = types.nullOr types.str;
        description = mdDoc ''
          Desktop file for the browser. It edit plain texts.
        '';
        default = null;
      };
      defaultImgViewer = mkOption {
        type = types.nullOr types.str;
        description = mdDoc ''
          Desktop file for the browser. It should be the default viewer for image files.
        '';
        default = null;
      };
      defaultTeamsViewer = mkOption {
        type = types.nullOr types.str;
        description = mdDoc ''
          Desktop file for the browser. It should be the default viewer for image files.
        '';
        default = "teams.desktop";
      };
      defaultArchiver = mkOption {
        type = types.nullOr types.str;
        description = mdDoc ''
          Desktop file for the browser. It should be able to manage all archiver files.
        '';
        default = null;
      };
      defaultDraw = mkOption {
        type = types.nullOr types.str;
        description = mdDoc ''
          Desktop file for DrawIo.
        '';
        default = "drawio.desktop";
      };
      defaultCode = mkOption {
        type = types.nullOr types.str;
        description = mdDoc "Vscode mime type.";
        default = "code.desktop";
      };
      defaultWord = mkOption {
        type = types.nullOr types.str;
        description = mdDoc ''
          Desktop file for word files.
        '';
        default = "writer.desktop";
      };
      defaultExcel = mkOption {
        type = types.nullOr types.str;
        description = mdDoc ''
          Desktop file for excel files.
        '';
        default = "calc.desktop";
      };
      defaultPowerPoint = mkOption {
        type = types.nullOr types.str;
        description = mdDoc ''
          Desktop file for powerpoint files.
        '';
        default = "calc.desktop";
      };
    };
  };

  config = {
    # xdg.mimeApps.defaultApplications = mkIf (cfg != null) {
    xdg =
      let
        associations = {
          # Webformats
          "x-scheme-handler/http" = cfg.defaultBrowser;
          "x-scheme-handler/https" = cfg.defaultBrowser;
          "x-scheme-handler/about" = cfg.defaultBrowser;
          "x-scheme-handler/ftp" = cfg.defaultBrowser;
          "x-scheme-handler/unknown" = cfg.defaultBrowser;
          "text/html" = cfg.defaultBrowser;
          "application/xhtml+xml" = cfg.defaultBrowser;
          "application/x-extension-htm" = cfg.defaultBrowser;
          "application/x-extension-html" = cfg.defaultBrowser;
          "application/x-extension-shtml" = cfg.defaultBrowser;
          "application/x-extension-xhtml" = cfg.defaultBrowser;
          "application/x-extension-xht" = cfg.defaultBrowser;


          # File Browser
          "inode/directory" = cfg.defaultFileManager;

          # Pdf
          "application/pdf" = cfg.defaultPdf;

          # Text
          "text/plain" = cfg.defaultPlainText;

          # vscode
          "x-scheme-handler/vscode" = cfg.defaultCode;

          # Images
          "image/gif" = cfg.defaultImgViewer;
          "image/heic" = cfg.defaultImgViewer;
          "image/png" = cfg.defaultImgViewer;
          "image/jpeg" = cfg.defaultImgViewer;
          "image/bmp" = cfg.defaultImgViewer;
          "image/jpg" = cfg.defaultImgViewer;
          "image/pjpeg" = cfg.defaultImgViewer;
          "image/tiff" = cfg.defaultImgViewer;
          "image/x-bmp" = cfg.defaultImgViewer;
          "image/x-gray" = cfg.defaultImgViewer;
          "image/x-icb" = cfg.defaultImgViewer;
          "image/x-ico" = cfg.defaultImgViewer;
          "image/x-png" = cfg.defaultImgViewer;
          "image/x-portable-anymap" = cfg.defaultImgViewer;
          "image/x-portable-bitmap" = cfg.defaultImgViewer;
          "image/x-portable-graymap" = cfg.defaultImgViewer;
          "image/x-portable-pixmap" = cfg.defaultImgViewer;
          "image/x-xbitmap" = cfg.defaultImgViewer;
          "image/x-xpixmap" = cfg.defaultImgViewer;
          "image/x-pcx" = cfg.defaultImgViewer;
          "image/svg+xml" = cfg.defaultImgViewer;
          "image/svg+xml-compressed" = cfg.defaultImgViewer;
          "image/vnd.wap.wbmp" = cfg.defaultImgViewer;
          "image/x-icns" = cfg.defaultImgViewer;

          # Team Viewer
          "x-scheme-handler/msteams" = cfg.defaultTeamsViewer;

          # Archives
          "application/x-rar-compressed" = cfg.defaultArchiver;
          "application/x-gtar" = cfg.defaultArchiver;
          "application/bzip2" = cfg.defaultArchiver;
          "application/gzip" = cfg.defaultArchiver;
          "application/vnd.rar" = cfg.defaultArchiver;
          "application/x-7z-compressed" = cfg.defaultArchiver;
          "application/x-7z-compressed-tar" = cfg.defaultArchiver;
          "application/x-bzip" = cfg.defaultArchiver;
          "application/x-bzip-compressed-tar" = cfg.defaultArchiver;
          "application/x-compress" = cfg.defaultArchiver;
          "application/x-compressed-tar" = cfg.defaultArchiver;
          "application/x-cpio" = cfg.defaultArchiver;
          "application/x-gzip" = cfg.defaultArchiver;
          "application/x-lha" = cfg.defaultArchiver;
          "application/x-lzip" = cfg.defaultArchiver;
          "application/x-lzip-compressed-tar" = cfg.defaultArchiver;
          "application/x-lzma" = cfg.defaultArchiver;
          "application/x-lzma-compressed-tar" = cfg.defaultArchiver;
          "application/x-tar" = cfg.defaultArchiver;
          "application/x-tarz" = cfg.defaultArchiver;
          "application/x-xar" = cfg.defaultArchiver;
          "application/x-xz" = cfg.defaultArchiver;
          "application/x-xz-compressed-tar" = cfg.defaultArchiver;
          "application/zip" = cfg.defaultArchiver;

          # Audio
          "audio/x-vorbis+ogg" = cfg.defaultAudioPlayer;
          "audio/ogg" = cfg.defaultAudioPlayer;
          "audio/vorbis" = cfg.defaultAudioPlayer;
          "audio/x-vorbis" = cfg.defaultAudioPlayer;
          "audio/x-speex" = cfg.defaultAudioPlayer;
          "audio/opus" = cfg.defaultAudioPlayer;
          "audio/flac" = cfg.defaultAudioPlayer;
          "audio/x-flac" = cfg.defaultAudioPlayer;
          "audio/x-ms-asf" = cfg.defaultAudioPlayer;
          "audio/x-ms-asx" = cfg.defaultAudioPlayer;
          "audio/x-ms-wax" = cfg.defaultAudioPlayer;
          "audio/x-ms-wma" = cfg.defaultAudioPlayer;
          "audio/x-pn-windows-acm" = cfg.defaultAudioPlayer;
          "audio/vnd.rn-realaudio" = cfg.defaultAudioPlayer;
          "audio/x-pn-realaudio" = cfg.defaultAudioPlayer;
          "audio/x-pn-realaudio-plugin" = cfg.defaultAudioPlayer;
          "audio/x-real-audio" = cfg.defaultAudioPlayer;
          "audio/x-realaudio" = cfg.defaultAudioPlayer;
          "audio/mpeg" = cfg.defaultAudioPlayer;
          "audio/mpg" = cfg.defaultAudioPlayer;
          "audio/mp1" = cfg.defaultAudioPlayer;
          "audio/mp2" = cfg.defaultAudioPlayer;
          "audio/mp3" = cfg.defaultAudioPlayer;
          "audio/x-mp1" = cfg.defaultAudioPlayer;
          "audio/x-mp2" = cfg.defaultAudioPlayer;
          "audio/x-mp3" = cfg.defaultAudioPlayer;
          "audio/x-mpeg" = cfg.defaultAudioPlayer;
          "audio/x-mpg" = cfg.defaultAudioPlayer;
          "audio/aac" = cfg.defaultAudioPlayer;
          "audio/m4a" = cfg.defaultAudioPlayer;
          "audio/mp4" = cfg.defaultAudioPlayer;
          "audio/x-m4a" = cfg.defaultAudioPlayer;
          "audio/x-aac" = cfg.defaultAudioPlayer;
          "audio/x-matroska" = cfg.defaultAudioPlayer;
          "audio/webm" = cfg.defaultAudioPlayer;
          "audio/3gpp" = cfg.defaultAudioPlayer;
          "audio/3gpp2" = cfg.defaultAudioPlayer;
          "audio/AMR" = cfg.defaultAudioPlayer;
          "audio/AMR-WB" = cfg.defaultAudioPlayer;
          "audio/mpegurl" = cfg.defaultAudioPlayer;
          "audio/x-mpegurl" = cfg.defaultAudioPlayer;
          "audio/scpls" = cfg.defaultAudioPlayer;
          "audio/x-scpls" = cfg.defaultAudioPlayer;
          "audio/dv" = cfg.defaultAudioPlayer;
          "audio/x-aiff" = cfg.defaultAudioPlayer;
          "audio/x-pn-aiff" = cfg.defaultAudioPlayer;
          "audio/wav" = cfg.defaultAudioPlayer;
          "audio/x-pn-au" = cfg.defaultAudioPlayer;
          "audio/x-pn-wav" = cfg.defaultAudioPlayer;
          "audio/x-wav" = cfg.defaultAudioPlayer;
          "audio/x-adpcm" = cfg.defaultAudioPlayer;
          "audio/ac3" = cfg.defaultAudioPlayer;
          "audio/eac3" = cfg.defaultAudioPlayer;
          "audio/vnd.dts" = cfg.defaultAudioPlayer;
          "audio/vnd.dts.hd" = cfg.defaultAudioPlayer;
          "audio/vnd.dolby.heaac.1" = cfg.defaultAudioPlayer;
          "audio/vnd.dolby.heaac.2" = cfg.defaultAudioPlayer;
          "audio/vnd.dolby.mlp" = cfg.defaultAudioPlayer;
          "audio/basic" = cfg.defaultAudioPlayer;
          "audio/midi" = cfg.defaultAudioPlayer;
          "audio/x-ape" = cfg.defaultAudioPlayer;
          "audio/x-gsm" = cfg.defaultAudioPlayer;
          "audio/x-musepack" = cfg.defaultAudioPlayer;
          "audio/x-tta" = cfg.defaultAudioPlayer;
          "audio/x-wavpack" = cfg.defaultAudioPlayer;
          "audio/x-shorten" = cfg.defaultAudioPlayer;
          "audio/x-it" = cfg.defaultAudioPlayer;
          "audio/x-mod" = cfg.defaultAudioPlayer;
          "audio/x-s3m" = cfg.defaultAudioPlayer;
          "audio/x-xm" = cfg.defaultAudioPlayer;

          # Video
          "video/x-ogm+ogg" = cfg.defaultVideoPlayer;
          "video/ogg" = cfg.defaultVideoPlayer;
          "video/x-ogm" = cfg.defaultVideoPlayer;
          "video/x-theora+ogg" = cfg.defaultVideoPlayer;
          "video/x-theora" = cfg.defaultVideoPlayer;
          "video/x-ms-asf" = cfg.defaultVideoPlayer;
          "video/x-ms-asf-plugin" = cfg.defaultVideoPlayer;
          "video/x-ms-asx" = cfg.defaultVideoPlayer;
          "video/x-ms-wm" = cfg.defaultVideoPlayer;
          "video/x-ms-wmv" = cfg.defaultVideoPlayer;
          "video/x-ms-wmx" = cfg.defaultVideoPlayer;
          "video/x-ms-wvx" = cfg.defaultVideoPlayer;
          "video/x-msvideo" = cfg.defaultVideoPlayer;
          "video/divx" = cfg.defaultVideoPlayer;
          "video/msvideo" = cfg.defaultVideoPlayer;
          "video/vnd.divx" = cfg.defaultVideoPlayer;
          "video/avi" = cfg.defaultVideoPlayer;
          "video/x-avi" = cfg.defaultVideoPlayer;
          "video/vnd.rn-realvideo" = cfg.defaultVideoPlayer;
          "video/mp2t" = cfg.defaultVideoPlayer;
          "video/mpeg" = cfg.defaultVideoPlayer;
          "video/mpeg-system" = cfg.defaultVideoPlayer;
          "video/x-mpeg" = cfg.defaultVideoPlayer;
          "video/x-mpeg2" = cfg.defaultVideoPlayer;
          "video/x-mpeg-system" = cfg.defaultVideoPlayer;
          "video/mp4" = cfg.defaultVideoPlayer;
          "video/mp4v-es" = cfg.defaultVideoPlayer;
          "video/x-m4v" = cfg.defaultVideoPlayer;
          "video/quicktime" = cfg.defaultVideoPlayer;
          "video/x-matroska" = cfg.defaultVideoPlayer;
          "video/webm" = cfg.defaultVideoPlayer;
          "video/3gp" = cfg.defaultVideoPlayer;
          "video/3gpp" = cfg.defaultVideoPlayer;
          "video/3gpp2" = cfg.defaultVideoPlayer;
          "video/vnd.mpegurl" = cfg.defaultVideoPlayer;
          "video/dv" = cfg.defaultVideoPlayer;
          "video/x-anim" = cfg.defaultVideoPlayer;
          "video/x-nsv" = cfg.defaultVideoPlayer;
          "video/fli" = cfg.defaultVideoPlayer;
          "video/flv" = cfg.defaultVideoPlayer;
          "video/x-flc" = cfg.defaultVideoPlayer;
          "video/x-fli" = cfg.defaultVideoPlayer;
          "video/x-flv" = cfg.defaultVideoPlayer;

          # Draw IO
          "application/vnd.jgraph.mxfile" = cfg.defaultDraw;

          # WordFormat
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = cfg.defaultWord;
          "application/vnd.openxmlformats-officedocument.wordprocessingml.template" = cfg.defaultWord;
          "application/vnd.oasis.opendocument.text" = cfg.defaultWord;
          "application/msword" = cfg.defaultWord;
          "application/vnd.ms-word.document.macroEnabled.12" = cfg.defaultWord;
          "application/vnd.ms-word.template.macroEnabled.12" = cfg.defaultWord;

          # ExcelFormats
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = cfg.defaultExcel;
          "application/vnd.openxmlformats-officedocument.spreadsheetml.template" = cfg.defaultExcel;
          "application/vnd.oasis.opendocument.spreadsheet" = cfg.defaultExcel;
          "application/msexcel" = cfg.defaultExcel;
          "application/vnd.ms-excel.sheet.macroEnabled.12" = cfg.defaultExcel;
          "application/vnd.ms-excel.template.macroEnabled.12" = cfg.defaultExcel;
          "application/vnd.ms-excel.addin.macroEnabled.12" = cfg.defaultExcel;
          "application/vnd.ms-excel.sheet.binary.macroEnabled.12" = cfg.defaultExcel;

          # Email
          "x-scheme-handler/mailto" = cfg.defaultEmail;

          # PowerPoint Formats
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" = cfg.defaultPowerPoint;
          "application/vnd.oasis.opendocument.presentation" = cfg.defaultPowerPoint;
          "application/vnd.openxmlformats-officedocument.presentationml.template" = cfg.defaultPowerPoint;
          "application/vnd.openxmlformats-officedocument.presentationml.slideshow" = cfg.defaultPowerPoint;
          "application/vnd.ms-powerpoint.addin.macroEnabled.12" = cfg.defaultPowerPoint;
          "application/vnd.ms-powerpoint.presentation.macroEnabled.12" = cfg.defaultPowerPoint;
          "application/vnd.ms-powerpoint.template.macroEnabled.12" = cfg.defaultPowerPoint;
          "application/vnd.ms-powerpoint.slideshow.macroEnabled.12" = cfg.defaultPowerPoint;
          "application/mspowerpoint" = cfg.defaultPowerPoint;
        };
      in
      mkIf cfg.enable {
        mimeApps =
          {
            enable = true;
            associations.added = associations;
            defaultApplications = associations;
          };
        configFile."mimeapps.list".force = mkIf (config.custom.features.nonNixOs.enable) true;

        portal = {
          configPackages = [ ] ++ lib.optionals (desktop == "hyprland") [
            pkgs.hyprland
          ];
          extraPortals = lib.optionals (desktop == "gnome") [
            pkgs.xdg-desktop-portal-gnome
          ] ++ lib.optionals (desktop == "hyprland") [
            pkgs.xdg-desktop-portal-hyprland
            pkgs.xdg-desktop-portal-gtk
          ]
          ++ lib.optionals (desktop == "bspwm") [
            pkgs.xdg-desktop-portal-gtk
          ] ++ lib.optionals (desktop == "mate" || desktop == "cinnamon") [
            pkgs.xdg-desktop-portal-xapp
            pkgs.xdg-desktop-portal-gtk
          ] ++ lib.optionals (desktop == "pantheon") [
            pkgs.pantheon.xdg-desktop-portal-pantheon
            pkgs.xdg-desktop-portal-gtk
          ];
          config = {
            common = {
              default = [ "gtk" ];
            };
            gnome = lib.mkIf (desktop == "gnome" || desktop == "bspwm") {
              default = [ "gnome" "gtk" ];
              "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            };
            hyprland = lib.mkIf (desktop == "hyprland") {
              default = [ "hyprland" "gtk" ];
              "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            };
            x-cinnamon = lib.mkIf (desktop == "mate" || desktop == "cinnamon") {
              default = [ "xapp" "gtk" ];
              "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            };
            pantheon = lib.mkIf (desktop == "pantheon") {
              default = [ "pantheon" "gtk" ];
              "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            };
          };
          xdgOpenUsePortal = true;
        };
      };



    home = {
      packages = with pkgs; [ junction ];
      activation."user-dirs" = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
        rm -f $VERBOSE_ARG "$HOME/.config/user-dirs.dirs.old"
      '';
    };
  };
}
