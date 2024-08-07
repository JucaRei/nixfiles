{ lib, pkgs, inputs, config, ... }:
with lib;
let
  cfg = config.services.brave;
in
{
  options.services.brave = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [
        # pkgs.brave
        (inputs.wrapper-manager.lib.build {
          inherit pkgs;
          modules = [ ./brave-x.nix ];
        })
      ];
      sessionVariables = lib.mkDefault {
        # DEFAULT_BROWSER = "${pkgs.brave}/bin/brave";
        BROWSER = "${pkgs.bravex}/bin/brave"; # for xdg-open
        CHROME_EXECUTABLE = "${pkgs.bravex}/bin/brave"; # for flutter
      };
    };

    xdg = {
      mime = { enable = true; };

      mimeApps = {
        enable = true;
        # defaultApplications = {
        #   "text/html" = "brave-browser.desktop";
        #   "x-scheme-handler/http" = "brave-browser.desktop";
        #   "x-scheme-handler/https" = "brave-browser.desktop";
        #   "x-scheme-handler/about" = "brave-browser.desktop";
        #   "x-scheme-handler/unknown" = "brave-browser.desktop";
        #   "applications/x-www-browser" = [ "brave-browser.desktop" ];
        # };
      };

      desktopEntries = {
        brave-browser = {
          # exec = ''
          #   ${pkgs.unstable.brave}/bin/brave --enable-features="VaapiVideoDecoder,VaapiVideoEncoder" --enable-raw-draw %U'';
          exec = ''
            ${pkgs.unstable.brave}/bin/brave --enable-features="VaapiVideoDecoder,VaapiVideoEncoder" --enable-raw-draw %U'';
          name = "Brave Browser";
          comment = "Access the Internet";
          genericName = "Web Browser";
          categories = [ "Network" "WebBrowser" ];
          icon = "brave-browser";
          mimeType = [
            "application/pdf"
            "application/x-www-browser"
            "application/rdf+xml"
            "application/rss+xml"
            "application/xhtml+xml"
            "application/xhtml_xml"
            "application/xml"
            "image/gif"
            "image/jpeg"
            "image/png"
            "image/webp"
            "text/html"
            "text/xml"
            "x-scheme-handler/unknown"
            "x-scheme-handler/about"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/ipfs"
            "x-scheme-handler/ipns"
          ];
          startupNotify = true;
          type = "Application";
        };
      };
    };
  };
}
