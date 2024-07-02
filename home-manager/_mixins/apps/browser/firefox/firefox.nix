{ pkgs, config, lib, params, nur, ... }:
with config;
with lib;
let
  inherit (pkgs.nur.repos.rycee) firefox-addons;

  nixGL = import ../../../../../lib/nixGL.nix { inherit config pkgs; };
  _ = lib.getExe;

  cfg = config.services.firefox;

  isGeneric = if (config.targets.genericLinux.enable) then true else false;

  sharedSettings = {
    "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
    "browser.crashReports.unsubmittedCheck.enabled" = false;
    "browser.fixup.dns_first_for_single_words" = false;
    "browser.newtab.extensionControlled" = true;
    "browser.search.update" = true;
    "browser.tabs.crashReporting.sendReport" = false;
    "browser.urlbar.suggest.bookmark" = false;
    "browser.urlbar.suggest.history" = true;
    "browser.urlbar.suggest.openpage" = false;
    "browser.tabs.warnOnClose" = false;
    "browser.urlbar.update2.engineAliasRefresh" = true;
    "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
    "dom.disable_window_flip" = true;
    "dom.disable_window_move_resize" = false;
    "dom.event.contextmenu.enabled" = true;
    "dom.reporting.crash.enabled" = false;
    "extensions.getAddons.showPane" = false;
    "media.gmp-gmpopenh264.enabled" = true;
    "media.gmp-widevinecdm.enabled" = true;
    "places.history.enabled" = true;
    "security.ssl.errorReporting.enabled" = false;
    "widget.use-xdg-desktop-portal.file-picker" = 1;
  };
  browser = "firefox";
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
        package = if (isGeneric) then (nixGL pkgs.unstable.firefox) else pkgs.unstable.firefox;
        policies = {
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;
          Cookies = {
            AcceptThirdParty = "from-visited";
            Behavior = "reject-tracker";
            BehaviorPrivateBrowsing = "reject-tracker";
            RejectTracker = true;
          };
          DisableAppUpdate = true;
          DisableDefaultBrowserAgent = true;
          DisableFormHistory = true;
          DisablePocket = true;
          DisableSetDesktopBackground = true;
          DisplayBookmarksToolbar = "never";
          DisplayMenuBar = "default-off";
          DNSOverHTTPS = {
            Enabled = false;
          };
          # DisableProfileImport = true;
          FirefoxHome = {
            Highlights = false;
            Locked = true;
            Pocket = false;
            Snippets = false;
            Search = true;
            SponsporedPocket = false;
            SponsporedTopSites = false;
            TopSites = false;
          };
          FirefoxSuggest = {
            WebSuggestions = false;
            SponsoredSuggestions = false;
            ImproveSuggest = false;
            Locked = true;
          };
          FlashPlugin = {
            Default = false;
          };
          Homepage = {
            Locked = false;
            StartPage = "previous-session";
          };
          NetworkPrediction = false;
          PopupBlocking = {
            Default = true;
          };
          PromptForDownloadLocation = true;
          SearchBar = "unified";
          OfferToSaveLogins = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          NewTabPage = true;
          HardwareAcceleration = true;
          CaptivePortal = false;
          DisableFirefoxAccounts = false;
          DisableFirefoxStudies = true;
          DisableTelemetry = true;
          NoDefaultBookmarks = true;
          PasswordManagerEnabled = true;
          DontCheckDefaultBrowser = true;
          EnableTrackingProtection = {
            Value = false;
            Locked = false;
            Cryptomining = true;
            EmailTracking = true;
            Fingerprinting = true;
          };
          EncryptedMediaExtensions = {
            Enabled = true;
            Locked = true;
          };
          SearchSuggestEnabled = true;
          ShowHomeButton = true;
          StartDownloadsInTempDirectory = true;
          SanitizeOnShutdown = {
            Cache = false;
            Downloads = false;
            #FormData = true;
            History = false;
            #Locked = true;
          };
          UserMessaging = {
            WhatsNew = false;
            ExtensionRecommendations = false;
            FeatureRecommendations = false;
            UrlbarInterventions = false;
            SkipOnboarding = true;
            MoreFromMozilla = false;
            Locked = false;
          };
          UseSystemPrintDialog = true;
        };
        nativeMessagingHosts = with pkgs; [
          #   bukubrow
          #   tridactyl-native
          fx-cast-bridge
        ];
        # ++ lib.optional config.programs.mpv.enable pkgs.ff2mpv;
        profiles = {
          Juca = {
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
        DEFAULT_BROWSER = "${_ config.programs.firefox.package}";
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
