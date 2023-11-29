{ pkgs, lib, params, ... }:
{
  programs = {
    firefox = {
      enable = true;
      languagePacks = [ "en-GB" "pt-BR" ];
      package = pkgs.unstable.firefox;
      policies = {
        CaptivePortal = false;
        DisableFirefoxAccounts = false;
        DisableFirefoxStudies = true;
        DisableTelemetry = true;
        NoDefaultBookmarks = true;
        PasswordManagerEnabled = true;
        DontCheckDefaultBrowser = true;
        SanitizeOnShutdown = {
          Cache = true;
          Downloads = true;
          #FormData = true;
          History = false;
          #Locked = true;
        };
        FirefoxHome = {
          Highlights = false;
          Pocket = false;
          Search = true;
          Snippets = false;
          TopSites = false;
        };
        search.engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }];

            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
        };

        search.force = true;

        bookmarks = [{
          name = "wikipedia";
          tags = [ "wiki" ];
          keyword = "wiki";
          url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
        }];
        SearchBar = "unified";
        SearchSuggestEnabled = true;
        ShowHomeButton = true;
        UserMessaging = {
          WhatsNew = false;
          ExtensionRecommendations = false;
          FeatureRecommendations = false;
          #UrlbarInterventions = false;
          SkipOnboarding = true;
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
        settings = {
          "browser.download.panel.shown" = true;
          "dom.security.https_only_mode" = true;
          "general.smoothScroll" = true;
          "gfx.webrender.enabled" = true;
          "layout.css.backdrop-filter.enabled" = true;
          "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
          "signon.rememberSignons" = false;
          "svg.context-properties.content.enabled" = true;

          # We handle this elsewhere
          "browser.shell.checkDefaultBrowser" = false;

          # Don't allow websites to prevent copy and paste. Disable
          # notifications of copy, paste, or cut functions. Stop webpage
          # knowing which part of the page had been selected.
          "dom.event.clipboardevents.enabled" = true;

          # Do not track from battery status.
          "dom.battery.enabled" = false;

          # Show punycode. Help protect from character 'spoofing'.
          "network.IDN_show_punycode" = true;

          # Disable site reading installed plugins.
          "plugins.enumerable_names" = "";

          # Use Mozilla instead of Google here.
          "geo.provider.network.url" =
            "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";

          # No speculative content when searching.
          # "browser.urlbar.speculativeConnect.enabled" = false;

          # Sends data to servers when leaving pages.
          "beacon.enabled" = false;
          # Informs servers about links that get clicked on by the user.
          "browser.send_pings" = false;

          "browser.tabs.closeWindowWithLastTab" = false;
          "browser.urlbar.placeholderName" = "DuckDuckGo";
          "browser.search.defaultenginename" = "DuckDuckGo";

          # Safe browsing
          "browser.safebrowsing.enabled" = false;
          "browser.safebrowsing.phishing.enabled" = false;
          "browser.safebrowsing.malware.enabled" = false;
          "browser.safebrowsing.downloads.enabled" = false;
          "browser.safebrowsing.provider.google4.updateURL" = "";
          "browser.safebrowsing.provider.google4.reportURL" = "";
          "browser.safebrowsing.provider.google4.reportPhishMistakeURL" = "";
          "browser.safebrowsing.provider.google4.reportMalwareMistakeURL" = "";
          "browser.safebrowsing.provider.google4.lists" = "";
          "browser.safebrowsing.provider.google4.gethashURL" = "";
          "browser.safebrowsing.provider.google4.dataSharingURL" = "";
          "browser.safebrowsing.provider.google4.dataSharing.enabled" = false;
          "browser.safebrowsing.provider.google4.advisoryURL" = "";
          "browser.safebrowsing.provider.google4.advisoryName" = "";
          "browser.safebrowsing.provider.google.updateURL" = "";
          "browser.safebrowsing.provider.google.reportURL" = "";
          "browser.safebrowsing.provider.google.reportPhishMistakeURL" = "";
          "browser.safebrowsing.provider.google.reportMalwareMistakeURL" = "";
          "browser.safebrowsing.provider.google.pver" = "";
          "browser.safebrowsing.provider.google.lists" = "";
          "browser.safebrowsing.provider.google.gethashURL" = "";
          "browser.safebrowsing.provider.google.advisoryURL" = "";
          "browser.safebrowsing.downloads.remote.url" = "";

          # Don't call home on new tabs
          "browser.selfsupport.url" = "";
          "browser.aboutHomeSnippets.updateUrL" = "";
          "browser.startup.homepage_override.mstone" = "ignore";
          "browser.startup.homepage_override.buildID" = "";
          "startup.homepage_welcome_url" = "";
          "startup.homepage_welcome_url.additional" = "";
          "startup.homepage_override_url" = "";

          # Firefox experiments...
          "experiments.activeExperiment" = false;
          "experiments.enabled" = false;
          "experiments.supported" = false;
          "extensions.pocket.enabled" = false;
          "identity.fxaccounts.enabled" = false;

          # Privacy
          "privacy.donottrackheader.enabled" = true;
          "privacy.donottrackheader.value" = 1;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.firstparty.isolate" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "browser.toolbars.bookmarks.visibility" = "never";

          # Cookies
          "network.cookie.cookieBehavior" = 1;

          # Perf
          "gfx.webrender.all" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "media.ffvpx.enabled" = false;
          "media.rdd-vpx.enabled" = false;
          "gfx.webrender.compositor.force-enabled" = true;
          "media.navigator.mediadatadecoder_vpx_enabled" = true;
          "webgl.force-enabled" = true;
          "layers.acceleration.force-enabled" = true;
          "layers.offmainthreadcomposition.enabled" = true;
          "layers.offmainthreadcomposition.async-animations" = true;
          "layers.async-video.enabled" = true;
          "html5.offmainthread" = true;
        };

        # userChrome = ''
        #   /* some css */
        # '';
        # modified theme from https://github.com/Bali10050/FirefoxCSS
        userChrome = builtins.readFile ../../../../home-manager/_mixins/config/firefox/FirefoxCSS/userChrome.css;
        userContent = builtins.readFile ../../../../home-manager/_mixins/config/firefox/FirefoxCSS/userContent.css;
      };
    };
  };
}
