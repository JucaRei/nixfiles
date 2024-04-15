{ pkgs, config, lib, params, nur, ... }:
with config;
with lib;
let
  inherit (pkgs.nur.repos.rycee) firefox-addons;

  nixGL = import ../../../../../lib/nixGL.nix { inherit config pkgs; };

  cfg = config.services.firefox;

  csshacks = pkgs.fetchFromGitHub {
    owner = "MrOtherGuy";
    repo = "firefox-csshacks";
    rev = "1ff9383984632fe91b8466730679e019de13c745";
    sha256 = "sha256-KmkiSpxzlsPBWoX51o27l+X1IEh/Uv8RMkihGRxg98o=";
  };

  nonNix = if (config.services.nonNixOs) then nixGL pkgs.firefox else pkgs.firefox;

  # ifDefault = lib.mkIf (builtins.elem params.browser [ "firefox" ]);

  sharedSettings = {
    # Privacy & Security Improvements
    #"browser.contentblocking.category" = "strict";
    "browser.urlbar.speculativeConnect.enabled" = true;
    "browser.search.openintab" = true;
    "browser.search.hiddenOneOffs" = "Google,Yahoo, Bing,Amazon.com,Twitter";
    "dom.security.https_only_mode" = true;
    "dom.event.clipboardevents.enabled" = true;
    "media.eme.enabled" = false; # disables DRM
    "media.navigator.enabled" = false;
    "network.cookie.cookieBehavior" = 1;
    # causes CORS error on waves.exchange when set to 2
    "network.http.referer.XOriginPolicy" = 1;
    # "network.http.referer.XOriginPolicy" = 2;
    "network.http.referer.XOriginTrimmingPolicy" = 2;
    "network.IDN_show_punycode" = true;
    "ui.systemUsesDarkTheme" = true; # 1 Default to dark
    "services.sync.prefs.sync.browser.uiCustomization.state" = true;
    # Enables userContent.css and userChrome.css for our theme modules
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    # Disables Activity Stream
    # forces ui.systemUsesDarkTheme to false
    # "privacy.resistFingerprinting" = true;
    # "webgl.disabled" = true;

    # Disable Telemetry
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.enabled" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "toolkit.telemetry.bhrPing.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
    "toolkit.telemetry.hybridContent.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.updatePing.enabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.healthreport.service.enabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    # Prevents search terms from being sent to ISP
    "browser.urlbar.dnsResolveSingleWordsAfterSearch" = 0;
    # Disables sponsored search results
    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;
    # Shows whole URL in address bar
    # "browser.urlbar.trimURLs" = false;
    # Disables non-useful funcionality of certain features
    # "browser.disableResetPrompt" = true;
    # "browser.onboarding.enabled" = false;
    # "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
    "extensions.pocket.enabled" = false;
    # "extensions.shield-recipe-client.enabled" = false;
    # "reader.parse-on-load.enabled" = false;
    # Allow seperate search-engine usage in private mode!
    "browser.search.separatePrivateDefault.ui.enabled" = true;
    # Uses Mozilla geolocation service instead of Google if given permission
    # "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
    # "geo.provider.use_gpsd" = false;
    # https://support.mozilla.org/en-US/kb/extension-recommendations
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" =
      false;
    "extensions.htmlaboutaddons.recommendations.enabled" = false;
    "extensions.htmlaboutaddons.discover.enabled" = false;
    "extensions.getAddons.showPane" = false; # Uses Google Analytics
    # "browser.discovery.enabled" = false;
    # Reduces File IO / SSD abuse, 15 seconds -> 30 minutes
    # "browser.sessionstore.interval" = "1800000";
    # Disables battery API
    "dom.battery.enabled" = false;
    # Disables "beacon" asynchronous HTTP transfers (used for analytics)
    "beacon.enabled" = false;
    # Disables pinging URIs specified in HTML <a> ping= attributes
    # Disables gamepad API to prevent USB device enumeration
    "dom.gamepad.enabled" = false;
    # Prevents guessing domain names on invalid entry in URL-bar
    # "browser.fixup.alternate.enabled" = false;
    # https://mozilla.github.io/normandy/
    # "app.normandy.api_url" = "";
    # Disables health reports (basically more telemetry)
    # Disables crash reports
    "breakpad.reportURL" = "";
    "browser.tabs.crashReporting.sendReport" = false;
    # Prevents the submission of backlogged reports
    "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

    # Disable Personalisation & Sponsored Content
    #"browser.discovery.enabled" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.feeds.snippets" = false;

    # Disable Experiments & Studies
    "experiments.activeExperiment" = false;
    "network.allow-experiments" = false;
    "app.normandy.enabled" = false;
    "app.shield.optoutstudies.enabled" = false;

    # Search
    #"browser.search.defaultenginename" = "DuckDuckGo";
    #"browser.search.selectedEngine" = "DuckDuckGo";

    # Disable DNS over HTTPS (done system-wide)
    #"network.trr.mode" = 5;

    # i18n
    "intl.accept_languages" = "en-GB, en, pt-BR";
    "intl.regional_prefs.use_os_locales" = true;

    # dev tools
    "devtools.inspector.color-scheme-simulation.enabled" = true;
    "devtools.inspector.showAllAnonymousContent" = true;

    # Disable Pocket
    "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
    "browser.newtabpage.activity-stream.section.highlights.includePocket" =
      false;
    "media.autoplay.enabled" = false;

    # Some privacy settings...
    "privacy.donottrackheader.enabled" = true;

    # Disables telemetry settings
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.server" = "data:,";
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.coverage.opt-out" = true;
    "toolkit.coverage.opt-out" = true;
    "toolkit.coverage.endpoint.base" = "";
    "experiments.supported" = false;
    "experiments.enabled" = false;
    "experiments.manifest.uri" = "";
    "browser.ping-centre.telemetry" = false;

    # Burn our own fingers.
    "privacy.resistFingerprinting" = true;
    "privacy.fingerprintingProtection" = true;
    "privacy.fingerprintingProtection.pbmode" = true;

    "privacy.query_stripping.enabled" = true;
    "privacy.query_stripping.enabled.pbmode" = true;

    "dom.security.https_first" = true;
    "dom.security.https_first_pbm" = true;

    "privacy.firstparty.isolate" = true;

    # Harden SSL
    "security.ssl.require_safe_negotiation" = true;

    # Other
    "browser.uitour.enabled" = false;
    "browser.startup.page" = 3;
    "browser.toolbars.bookmarks.visibility" = "newtab";
    "browser.tabs.drawInTitlebar" = true;
    "signon.rememberSignons" = false;
    #"services.sync.engine.passwords" = false;
    #"extensions.update.enabled" = false;
    #"extensions.update.autoUpdateDefault" = false;

    userChrome = builtins.concatStringsSep "\n" (builtins.map builtins.readFile
      [
        "${csshacks}/chrome/hide_tabs_toolbar.css"
        # Preferable, but there's too many bugs with menu dropdowns not dropping
        # up when they're at the bottom of the screen
        # "${csshacks}/chrome/navbar_below_content.css"
      ]);
  };
  # librewolf-gl = with pkgs; wrapFirefox librewolf-unwrapped {
  firefox-gl = with pkgs.unstable;
    wrapFirefox firefox-unwrapped {
      # floorp-gl = with pkgs.unstable; wrapFirefox floorp-unwrapped {
      # firefox-gl = with pkgs.unstable; wrapFirefox firefox-devedition-unwrapped {
    };

  browser = "firefox";
  # browser = "floorp";
  # browser = "librewolf";
in
{

  options.services.firefox = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    programs = {
      firefox = {
        enable = true;
        # package = pkgs.unstable.firefox;
        package = nonNix;
        # package = floorp-gl;
        # package = librewolf-gl;
        policies = {
          FirefoxHome = {
            Highlights = false;
            Pocket = false;
            Snippets = false;
            Search = true;
            SponsporedPocket = false;
            SponsporedTopSites = false;
            TopSites = false;
          };
          CaptivePortal = false;
          DisableFirefoxAccounts = false;
          DisableFirefoxStudies = true;
          DisableTelemetry = true;
          NoDefaultBookmarks = true;
          PasswordManagerEnabled = true;
          DontCheckDefaultBrowser = true;
          EnableTrackingProtection = true;
          SearchBar = "unified";
          SearchSuggestEnabled = true;
          ShowHomeButton = true;
          SanitizeOnShutdown = {
            Cache = true;
            Downloads = true;
            #FormData = true;
            History = false;
            #Locked = true;
          };
          UserMessaging = {
            WhatsNew = false;
            ExtensionRecommendations = false;
            FeatureRecommendations = false;
            #UrlbarInterventions = false;
            SkipOnboarding = true;
            MoreFromMozilla = false;
          };
        };
        # nativeMessagingHosts = with pkgs; [
        #   bukubrow
        #   tridactyl-native
        #   fx-cast-bridge
        # ];
        # ++ lib.optional config.programs.mpv.enable pkgs.ff2mpv;
        profiles = {
          juca = {
            id = 0;
            settings = sharedSettings;
            isDefault = true;
            extensions = with pkgs.nur.repos.rycee.firefox-addons; [
              #   # Install extensions from NUR
              #   decentraleyes
              ublock-origin
              return-youtube-dislikes
              don-t-fuck-with-paste
              noscript
              search-by-image
              #   clearurls
              sponsorblock
              #   darkreader
              #   h264ify
              #   df-youtube
            ];
            search = {
              engines = {
                "NixOS Options" = {
                  urls = [
                    {
                      template = "https://search.nixos.org/options";
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
                    }
                  ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@no" ];
                };
                "Nix Packages" = {
                  urls = [
                    {
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
                    }
                  ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@np" ];
                };
                "NixOS Wiki" = {
                  urls = [
                    {
                      template = "https://nixos.wiki/index.php?search={searchTerms}";
                    }
                  ];
                  definedAliases = [ "@nw" ];
                };
                "Brave" = {
                  urls = [{
                    template = "https://search.brave.com/search";
                    params = [
                      { name = "type"; value = "search"; }
                      { name = "q"; value = "{searchTerms}"; }
                    ];
                  }];
                  icon = "${config.programs.brave.package}/share/icons/hicolor/64x64/apps/brave-browser.png";
                  definedAliases = [ "@brave" "@b" ];
                };

                "Bing".metaData.hidden = true;
                "Google".metaData.alias = "@g";
                "Wikipedia".metaData.alias = "@wiki";
              };
              default = "Google";
              force = true;
            };
            bookmarks = [
              {
                name = "BJ-Share";
                url = "https://bj-share.info/";
              }
              {
                name = "kernel.org";
                url = "https://www.kernel.org";
              }
              {
                name = "Sourcegraph";
                tags = [ "code" "wiki" ];
                url = "https://www.sourcegraph.com/search";
              }
              {
                name = "Nix sites";
                toolbar = true;
                bookmarks = [
                  {
                    name = "homepage";
                    url = "https://nixos.org/";
                  }
                  {
                    name = "wiki";
                    tags = [ "wiki" "nix" ];
                    url = "https://nixos.wiki/";
                  }
                  {
                    name = "home-manager options";
                    tags = [ "wiki" "nix" "home-manager" ];
                    url = "https://home-manager-options.extranix.com/";
                  }
                  {
                    name = "Mynixos";
                    tags = [ "wiki" "nix" "nix-modules" ];
                    url = "https://mynixos.com/";
                  }
                ];
              }
            ];
          };
        };
      };
    };

    home = {
      sessionVariables = {
        DEFAULT_BROWSER = "${firefox-gl}/bin/${browser}";
        # DEFAULT_BROWSER = "${floorp-gl}/bin/${browser}";
        # DEFAULT_BROWSER = "${librewolf-gl}/bin/${browser}";
      };
    };

    xdg.mimeApps.defaultApplications = {
      "application/x-extension-htm" = "${browser}.desktop";
      "application/x-extension-html" = "${browser}.desktop";
      "application/x-extension-shtml" = "${browser}.desktop";
      "application/x-extension-xht" = "${browser}.desktop";
      "application/x-extension-xhtml" = "${browser}.desktop";
      "application/xhtml+xml" = "${browser}.desktop";
      "text/html" = "${browser}.desktop";
      "x-scheme-handler/chrome" = "${browser}.desktop";
      "x-scheme-handler/http" = "${browser}.desktop";
      "x-scheme-handler/https" = "${browser}.desktop";
    };
  };
}
