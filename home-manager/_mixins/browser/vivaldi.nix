{ pkgs, ... }: {

  # Module installing vivaldi as default browser
  home = {
    packages = with pkgs.unstable; [
      vivaldi
      vivaldi-ffmpeg-codecs
    ];
    sessionVariables = {
      DEFAULT_BROWSER = "${pkgs.vivaldi}/bin/vivaldi";
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = "vivaldi-browser.desktop";
    "x-scheme-handler/http" = "vivaldi-browser.desktop";
    "x-scheme-handler/https" = "vivaldi-browser.desktop";
    "x-scheme-handler/about" = "vivaldi-browser.desktop";
    "x-scheme-handler/unknown" = "vivaldi-browser.desktop";
  };
}
