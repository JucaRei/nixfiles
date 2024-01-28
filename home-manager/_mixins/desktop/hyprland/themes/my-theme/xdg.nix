{ config, lib, pkgs, ... }:
let
  file-manager = "thunar.desktop";
  compressed = "xarchiver.desktop";
  browser = "firefox.desktop";
  viewer = "imv.desktop";
  video = "umpv.desktop";
  audio = "org.gnome.Rhythmbox3.desktop";
in {
  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = file-manager;
        "text/html" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/mailto" = browser; # TODO
        "x-scheme-handler/chrome" = browser;
        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "application/x-extension-shtml" = browser;
        "application/xhtml+xml" = browser;
        "application/x-extension-xhtml" = browser;
        "application/x-extension-xht" = browser;

        # Compression
        "application/bzip2" = compressed;
        "application/gzip" = compressed;
        "application/vnd.rar" = compressed;
        "application/x-7z-compressed" = compressed;
        "application/x-7z-compressed-tar" = compressed;
        "application/x-bzip" = compressed;
        "application/x-bzip-compressed-tar" = compressed;
        "application/x-compress" = compressed;
        "application/x-compressed-tar" = compressed;
        "application/x-cpio" = compressed;
        "application/x-gzip" = compressed;
        "application/x-lha" = compressed;
        "application/x-lzip" = compressed;
        "application/x-lzip-compressed-tar" = compressed;
        "application/x-lzma" = compressed;
        "application/x-lzma-compressed-tar" = compressed;
        "application/x-tar" = compressed;
        "application/x-tarz" = compressed;
        "application/x-xar" = compressed;
        "application/x-xz" = compressed;
        "application/x-xz-compressed-tar" = compressed;
        "application/zip" = compressed;
      };
    };
  };
}
