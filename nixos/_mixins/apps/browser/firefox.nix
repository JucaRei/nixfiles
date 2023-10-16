{ pkgs, lib, params, ... }:
{
  programs = {
    firefox = {
      enable = true;
      languagePacks = [ "en-GB" "pt-BR" ];
      package = pkgs.unstable.firefox;
      policies = {
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        SanitizeOnShutdown = {
          Cache = true;
          Downloads = true;
          #FormData = true;
          History = true;
          #Locked = true;
        };
        SearchBar = "unified";
        SearchSuggestEnabled = true;
        ShowHomeButton = true;
        UserMessaging = {
          WhatsNew = false;
          ExtensionRecommendations = false;
          FeatureRecommendations = false;
          #UrlbarInterventions = false;
          #SkipOnboarding = true;
          MoreFromMozilla = false;
        };
        preferences = {
          "browser.aboutConfig.showWarning" = false;
          "gfx.webrender.all" = true;
          "gfx.webrender.compositor.force-enabled" = true;
          "gfx.x11-egl.force-enabled" = true;
          "media.av1.enabled" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "media.hardware-video-decoding.force-enabled" = true;
          "media.hls.enabled" = true;
          "media.videocontrols.picture-in-picture.enabled" = false;
          "security.insecure_connection_text.enabled" = true;
          "security.insecure_connection_text.pbmode.enabled" = true;
          "security.osclientcerts.autoload" = true;
        };
        # preferencesStatus = "locked";
      };
    };
  };
}
