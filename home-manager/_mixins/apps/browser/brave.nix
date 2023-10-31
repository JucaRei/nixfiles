{ lib, params, pkgs, ... }:
{
  home = {
    packages = [ pkgs.brave ];
    sessionVariables = {
      DEFAULT_BROWSER = "${pkgs.brave}/bin/brave";
    };
  };

  xdg = {
    mime = {
      enable = true;
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "brave-browser.desktop";
        "x-scheme-handler/http" = "brave-browser.desktop";
        "x-scheme-handler/https" = "brave-browser.desktop";
        "x-scheme-handler/about" = "brave-browser.desktop";
        "x-scheme-handler/unknown" = "brave-browser.desktop";
      };
    };
  };
}
