# { config, lib, pkgs, wmType, font, params, ... }:
{ config
, pkgs
, ...
}:
let
  nixGL = import ../../../lib/nixGL.nix { inherit config pkgs; };
  librewolf = nixGL pkgs.librewolf;
in
{
  # Module installing librewolf as default browser
  # home.packages = [ pkgs.librewolf ];

  programs = {
    librewolf = {
      enable = true;
      package = librewolf;
      settings = {
        "ui.use_activity_cursor" = true;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.quitShortcut.disabled" = true;
        "findbar.highlightAll" = true;
      };
    };
  };

  home.sessionVariables =
    # if (wmType == "wayland")
    # then { DEFAULT_BROWSER = "${pkgs.librewolf-wayland}/bin/librewolf"; }
    # else
    # { DEFAULT_BROWSER = "${pkgs.librewolf}/bin/librewolf"; };
    {
      DEFAULT_BROWSER = "${librewolf}/bin/librewolf";
    };

  # defaultPref("font.name.serif.x-western","'' + font + ''");
  # pref("font.name.serif.x-western","'' + font + ''");

  # defaultPref("webgl.disabled",true);
  # defaultPref("gfx.webrender.software.opengl",false);

  home.file.".librewolf/librewolf.overrides.cfg".text = ''
    defaultPref("font.name.serif.x-western");

    defaultPref("font.size.variable.x-western",20);
    defaultPref("browser.toolbars.bookmarks.visibility","always");
    defaultPref("identity.fxaccounts.enabled", true);
    defaultPref("privacy.resisttFingerprinting.letterboxing", true);
    defaultPref("network.http.referer.XOriginPolicy",2);
    defaultPref("privacy.clearOnShutdown.history",false);
    defaultPref("privacy.clearOnShutdown.downloads",true);
    defaultPref("privacy.clearOnShutdown.cookies",false);
    defaultPref("webgl.dxgl.enabled", true);
    defaultPref("webgl.disabled", false);
    pref("font.name.serif.x-western");
    defaultPref("webgl.enable-webgl2", true);
    defaultPref("webgl.min_capability_mode", false);
    defaultPref("webgl.disable-extensions", false);
    defaultPref("webgl.disable-fail-if-major-performance-caveat", true);
    defaultPref("webgl.enable-debug-renderer-info", true);

    defaultPref("pdfjs.enableWebGL", true);

    defaultPref("dom.event.clipboardevents.enabled", true);

    defaultPref("dom.webaudio.enabled", true);

    defaultPref("identity.fxaccounts.enabled", true);

    pref("font.size.variable.x-western",20);
    pref("browser.toolbars.bookmarks.visibility","always");
    pref("privacy.resisttFingerprinting.letterboxing", true);
    pref("network.http.referer.XOriginPolicy",2);
    pref("privacy.clearOnShutdown.history",false);
    pref("privacy.clearOnShutdown.downloads",true);
    pref("privacy.clearOnShutdown.cookies",false);
    pref("gfx.webrender.software.opengl",false);
    pref("webgl.disabled",true);
  '';

  xdg.mimeApps.defaultApplications = {
    "application/x-extension-htm" = "librewolf.desktop";
    "application/x-extension-html" = "librewolf.desktop";
    "application/x-extension-shtml" = "librewolf.desktop";
    "application/x-extension-xht" = "librewolf.desktop";
    "application/x-extension-xhtml" = "librewolf.desktop";
    "application/xhtml+xml" = "librewolf.desktop";
    "text/html" = "librewolf.desktop";
    "x-scheme-handler/chrome" = "librewolf.desktop";
    "x-scheme-handler/http" = "librewolf.desktop";
    "x-scheme-handler/https" = "librewolf.desktop";
  };
}
