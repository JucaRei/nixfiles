{ lib, pkgs, inputs, ... }:
with lib.hm.gvariant; {
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  # Add the Firefox integrations
  programs.firefox.profiles.default.extensions = with pkgs.nur.repos.rycee.firefox-addons; [ plasma-integration ];

  xdg = {
    mime = {
      enable = true;
    };
    mimeApps = {
      enable = true;
      defaultApplications = { };
      associations = {
        added = {
          "application/x-extension-htm" = [ "firefox.desktop" ];
          "application/x-extension-html" = [ "firefox.desktop" ];
          "application/x-extension-shtml" = [ "firefox.desktop" ];
          "application/x-extension-xht" = [ "firefox.desktop" ];
          "application/x-extension-xhtml" = [ "firefox.desktop" ];
          "application/xhtml+xml" = [ "firefox.desktop" ];
          "x-scheme-handler/http" = [ "firefox.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" ];
          "x-scheme-handler/unknown" = [ "firefox.desktop" ];
          "x-scheme-handler/ftp" = [ "firefox.desktop" ];
          "x-scheme-handler/about" = [ "firefox.desktop" ];
          "x-scheme-handler/chrome" = [ "firefox.desktop" ];
          "text/uri-list" = [ "firefox.desktop" ];
          "application/x-ms-dos-executable" = [ "wine.desktop" ];
          "x-scheme-handler/discord" = [ "discord.desktop" ];
          "application/pdf" = [ "org.kde.okular.desktop" ];
          "application/pgp-encrypted" = [ "org.kde.kgpg.desktop" ];
          "application/vnd.ms-publisher" = [ "org.kde.kate.desktop" ];
          "application/xml" = [ "org.kde.kate.desktop" ];
          "text/markdown" = [ "org.kde.kate.desktop" ];
          "text/plain" = [ "org.kde.kate.desktop" ];
          "x-scheme-handler/geo" = [ "marble_geo.desktop" ];
          "x-scheme-handler/mailto" = [ "org.kde.kmail2.desktop" ];
          "x-scheme-handler/tel" = [ "org.kde.kdeconnect.handler.desktop" ];
          "video/mp4" = [ "mpv.desktop" ];
          "video/ogg" = [ "mpv.desktop" ];
          "video/webm" = [ "mpv.desktop" ];
          "video/x-flv" = [ "mpv.desktop" ];
          "video/x-matroska" = [ "mpv.desktop" ];
          "video/x-ms-wmv" = [ "mpv.desktop" ];
          "video/x-ogm+ogg" = [ "mpv.desktop" ];
          "video/x-theora+ogg" = [ "mpv.desktop" ];
          "audio/aac" = [ "org.kde.elisa.desktop" ];
          "audio/flac" = [ "org.kde.elisa.desktop" ];
          "audio/mp4" = [ "org.kde.elisa.desktop" ];
          "audio/mpeg" = [ "org.kde.elisa.desktop" ];
          "audio/ogg" = [ "org.kde.elisa.desktop" ];
          "audio/x-wav" = [ "org.kde.elisa.desktop" ];
          "image/gif" = [ "org.kde.gwenview.desktop" ];
          "image/jpeg" = [ "org.kde.gwenview.desktop" ];
          "image/png" = [ "org.kde.gwenview.desktop" ];
          "image/svg+xml" = [ "org.inkscape.Inkscape.desktop" ];
          "image/vnd.adobe.photoshop" = [ "krita_psd.desktop" ];
          "image/webp" = [ "org.kde.gwenview.desktop" ];
          "image/x-eps" = [ "org.inkscape.Inkscape.desktop" ];
          "image/x-xcf" = [ "gimp.desktop" ];
          "inode/directory" = [ "org.kde.dolphin.desktop" ];
        };
        removed = { };
      };
    };
  };
}
