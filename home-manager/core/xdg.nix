{ config, lib, ... }:
let
  cfg = config.mime.defaultApps;
  inherit (lib) types mkEnableOption mkOption mdDoc mkIf;
in
{
  options = {
    mime.defaultApps = {
      enable = mkEnableOption (mdDoc "Enable default mime for selected SYSTEM.");
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
    xdg.mimeApps.associations.added = mkIf cfg.enable {
      # xdg.mimeApps.defaultApplications = mkIf cfg.enable {
      "text/html" = cfg.defaultBrowser;
      "text/xml" = cfg.defaultBrowser;
      "x-scheme-handler/http" = cfg.defaultBrowser;
      "x-scheme-handler/https" = cfg.defaultBrowser;
      "x-scheme-handler/mailto" = cfg.defaultBrowser; # TODO
      "x-scheme-handler/chrome" = cfg.defaultBrowser;
      "application/x-extension-htm" = cfg.defaultBrowser;
      "application/x-extension-html" = cfg.defaultBrowser;
      "application/x-extension-shtml" = cfg.defaultBrowser;
      "application/xhtml+xml" = cfg.defaultBrowser;
      "application/x-extension-xhtml" = cfg.defaultBrowser;
      "application/x-extension-xht" = cfg.defaultBrowser;

      "inode/directory" = cfg.defaultFileManager;

      "application/pdf" = cfg.defaultPdf;

      "text/plain" = cfg.defaultPlainText;

      "image/gif" = cfg.defaultImgViewer;
      "image/heic" = cfg.defaultImgViewer;
      "image/jpeg" = cfg.defaultImgViewer;
      "image/png" = cfg.defaultImgViewer;

      "x-scheme-handler/msteams" = cfg.defaultTeamsViewer;

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

      "application/vnd.jgraph.mxfile" = cfg.defaultDraw;
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = cfg.defaultWord;
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = cfg.defaultExcel;
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = cfg.defaultPowerPoint;
      "application/msword" = cfg.defaultWord;
      "application/msexcel" = cfg.defaultExcel;
      "application/mspowerpoint" = cfg.defaultPowerPoint;
      "application/vnd.oasis.opendocument.text" = cfg.defaultWord;
      "application/vnd.oasis.opendocument.spreadsheet" = cfg.defaultExcel;
      "application/vnd.oasis.opendocument.presentation" = cfg.defaultPowerPoint;
    };
  };
}
