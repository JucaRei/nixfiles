# { config, lib, pkgs, wmType, font, params, ... }:
{ config, pkgs, ... }:
{
  # Module installing librewolf as default browser
  # home.packages = [ pkgs.librewolf ];

  programs = {
    librewolf = {
      enable = true;
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
      DEFAULT_BROWSER = "${pkgs.librewolf}/bin/librewolf";
    };

  # defaultPref("font.name.serif.x-western","'' + font + ''");
  # pref("font.name.serif.x-western","'' + font + ''");

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
    defaultPref("gfx.webrender.software.opengl",false);
    defaultPref("webgl.disabled",true);
    pref("font.name.serif.x-western");

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
    "text/html" = "librewolf.desktop";
    "x-scheme-handler/http" = "librewolf.desktop";
    "x-scheme-handler/https" = "librewolf.desktop";
    "x-scheme-handler/about" = "librewolf.desktop";
    "x-scheme-handler/unknown" = "librewolf.desktop";
  };

}
