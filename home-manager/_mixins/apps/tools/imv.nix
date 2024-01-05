_:
let
  image-viewer = "imv.desktop";
in
{
  programs = {
    imv = {
      enable = true;
      settings = { };
    };
  };

  xdg.mimeApps = rec {
    enable = true;
    associations.added = defaultApplications;
    defaultApplications = {
      "image/jpeg" = image-viewer;
      "image/bmp" = image-viewer;
      "image/gif" = image-viewer;
      "image/jpg" = image-viewer;
      "image/pjpeg" = image-viewer;
      "image/png" = image-viewer;
      "image/tiff" = image-viewer;
      "image/webp" = image-viewer;
      "image/x-bmp" = image-viewer;
      "image/x-gray" = image-viewer;
      "image/x-icb" = image-viewer;
      "image/x-ico" = image-viewer;
      "image/x-png" = image-viewer;
      "image/x-portable-anymap" = image-viewer;
      "image/x-portable-bitmap" = image-viewer;
      "image/x-portable-graymap" = image-viewer;
      "image/x-portable-pixmap" = image-viewer;
      "image/x-xbitmap" = image-viewer;
      "image/x-xpixmap" = image-viewer;
      "image/x-pcx" = image-viewer;
      "image/svg+xml" = image-viewer;
      "image/svg+xml-compressed" = image-viewer;
      "image/vnd.wap.wbmp" = image-viewer;
      "image/x-icns" = image-viewer;
    };
  };
}
