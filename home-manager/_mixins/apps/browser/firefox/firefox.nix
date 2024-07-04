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
    "devtools.theme" = "dark";
    "distribution.searchplugins.defaultLocale" = "en-US";
    "general.useragent.locale" = "en-US";
    "general.useragent.compatMode.firefox" = true;
    "browser.tabs.tabMinWidth" = 16;
    "browser.toolbars.bookmarks.visibility" = "never";
    "browser.startup.page" = 3; # Restore previous tabs
    "browser.uiCustomization.state" = ''
      {
        "placements":{
          "widget-overflow-fixed-list":[],"unified-extensions-area":["_2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c_-browser-action","_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action","dontfuckwithpaste_raim_ist-browser-action","tab-stash_condordes_net-browser-action","_48be9eda-8d28-4a3c-8c1c-cd6161dbf076_-browser-action"],
          "nav-bar":[
            "back-button","forward-button","stop-reload-button","customizableui-special-spring1","home-button","urlbar-container","history-panelmenu","customizableui-special-spring2","save-to-pocket-button","downloads-button","fxa-toolbar-menu-button","unified-extensions-button","sponsorblocker_ajay_app-browser-action","ublock0_raymondhill_net-browser-action","_8fbc7259-8015-4172-9af1-20e1edfbbd3a_-browser-action"],
            "toolbar-menubar":[
              "menubar-items"
            ],
            "TabsToolbar":[
              "firefox-view-button","tabbrowser-tabs","new-tab-button","alltabs-button"
              ],
              "PersonalToolbar":[
                  "import-button","personal-bookmarks"
                ]
              },"seen":[
                "developer-button","_2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c_-browser-action","_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action","dontfuckwithpaste_raim_ist-browser-action","sponsorblocker_ajay_app-browser-action","ublock0_raymondhill_net-browser-action","tab-stash_condordes_net-browser-action","_48be9eda-8d28-4a3c-8c1c-cd6161dbf076_-browser-action","_8fbc7259-8015-4172-9af1-20e1edfbbd3a_-browser-action"
                ],
                "dirtyAreaCache":[
                  "nav-bar","PersonalToolbar","unified-extensions-area","toolbar-menubar","TabsToolbar"
                  ],
                  "currentVersion":20,
                  "newElementCount":3
            }
    '';
    "browser.disableResetPrompt" = true;
    "browser.download.panel.shown" = true;
    "browser.startup.homepage" = "https://www.uol.com.br/";
    "browser.shell.checkDefaultBrowser" = false;
    "browser.shell.defaultBrowserCheckCount" = 1;

    # Enable userContent.css and userChrome.css for our theme modules
    "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
    "browser.crashReports.unsubmittedCheck.enabled" = false;
    "browser.fixup.dns_first_for_single_words" = false;
    "browser.newtab.extensionControlled" = true;
    "browser.search.update" = true;
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
    "media.ffvpx.enabled" = false;
    # disable av1, vaapi on old hardware does not support av1
    "media.av1.enabled" = false;
    "media.ffmpeg.vaapi.enabled" = true;
    "places.history.enabled" = true;
    "security.ssl.errorReporting.enabled" = false;
    "widget.use-xdg-desktop-portal.file-picker" = 1; # Always use XDG portals for stuff
    "security.identityblock.show_extended_validation" = true;
    # Show more ssl cert infos
    "experiments.supported" = false;
    "experiments.enabled" = false;
    "experiments.manifest.uri" = "";
    "datareporting.healthreport.service.enabled" = false;
    # privacy tweaks
    "browser.contentblocking.category" = "strict";
    "intl.accept_languages" = "en-US, en";
    "javascript.use_us_english_locale" = true;
    "privacy.clearOnShutdown.cache" = false;
    "privacy.clearOnShutdown.cookies" = false;
    "privacy.clearOnShutdown.downloads" = false;
    "privacy.clearOnShutdown.formdata" = false;
    "privacy.clearOnShutdown.history" = false;
    "privacy.clearOnShutdown.offlineApps" = false;
    "privacy.clearOnShutdown.sessions" = false;
    "privacy.fingerprintingProtection" = true;
    "privacy.trackingprotection.enabled" = true;
    "privacy.trackingprotection.emailtracking.enabled" = true;
    "privacy.trackingprotection.socialtracking.enabled" = true;

    # Smooth Scroll
    "general.smoothScroll" = true;
    "general.smoothScroll.lines.durationMaxMS" = 125;
    "general.smoothScroll.lines.durationMinMS" = 125;
    "general.smoothScroll.mouseWheel.durationMaxMS" = 200;
    "general.smoothScroll.mouseWheel.durationMinMS" = 100;
    "general.smoothScroll.msdPhysics.enabled" = true;
    "general.smoothScroll.other.durationMaxMS" = 125;
    "general.smoothScroll.other.durationMinMS" = 125;
    "general.smoothScroll.pages.durationMaxMS" = 125;
    "general.smoothScroll.pages.durationMinMS" = 125;
    "mousewheel.min_line_scroll_amount" = 30;
    "mousewheel.system_scroll_override_on_root_content.enabled" = true;
    "mousewheel.system_scroll_override_on_root_content.horizontal.factor" = 175;
    "mousewheel.system_scroll_override_on_root_content.vertical.factor" = 175;
    "toolkit.scrollbox.horizontalScrollDistance" = 6;
    "toolkit.scrollbox.verticalScrollDistance" = 2;

    # Firefox GNOME Theme
    # Hide the tab bar when only one tab is open.
    "gnomeTheme.hideSingleTab" = true;
    # By default the tab close buttons follows the position of the window controls, this preference reverts that behavior.
    "gnomeTheme.swapTabClose" = true;
    # Move Bookmarks toolbar under tabs.
    "gnomeTheme.bookmarksToolbarUnderTabs" = true;
    # Hide WebRTC indicator since GNOME provides their own privacy icons in the top right.
    "gnomeTheme.hideWebrtcIndicator" = true;
    # Use system theme icons instead of Adwaita icons included by theme.
    "gnomeTheme.systemIcons" = true;

    # Disable permission
    # 0=always ask (default), 1=allow, 2=block
    "permissions.default.geo" = 2;
    "permissions.default.camera" = 2;
    "permissions.default.microphone" = 0;
    "permissions.default.desktop-notification" = 2;
    "permissions.default.xr" = 2; # Virtual Reality
    "browser.discovery.enabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "app.shield.optoutstudies.enabled" = false;
    "app.normandy.enabled" = false;
    "app.normandy.api_url" = "";

    # Tweaks from archwiki
    "browser.cache.disk.enable" = false;
    "browser.cache.memory.enable" = true;
    "browser.cache.memory.capacity" = -1;
    "browser.aboutConfig.showWarning" = false;
    "browser.preferences.defaultPerformanceSettings.enabled" = false;
    "middlemouse.paste" = false;

    # (copied into here because home-manager already writes to user.js)
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # Enable customChrome.cs
    "browser.uidensity" = 0; # Set UI density to normal
    "svg.context-properties.content.enabled" = true; # Enable SVG context-propertes

    # Harden SSL
    "security.ssl.require_safe_negotiation" = true;

    # # Disable Pocket
    "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
    "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "extensions.pocket.enabled" = false;

    # Disable telemetry
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.ping-centre.telemetry" = false;
    "browser.tabs.crashReporting.sendReport" = false;
    "devtools.onboarding.telemetry.logged" = false;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.server" = "data:,";
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.updatePing.enabled" = false;
    "toolkit.telemetry.bhrPing.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
  };

  custom-policies = {
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
      firefox =
        let
          firefox-dev = pkgs.unstable.firefox-devedition;
        in
        {
          enable = true;
          package = if (isGeneric) then (nixGL pkgs.unstable.firefox) else pkgs.unstable.firefox;
          # package = if (isGeneric) then (nixGL firefox-dev) else firefox-dev;
          policies = custom-policies;
          nativeMessagingHosts = with pkgs;
            [
              bukubrow
              tridactyl-native
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
                # midnight-lizard
                # noscript
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
                            name = "channel";
                            value = "unstable";
                          }
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
                            name = "channel";
                            value = "unstable";
                          }
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
                  "Home Manager Options" = {
                    urls = [{ template = "https://home-manager-options.extranix.com/?query={searchTerms}&release = master "; }];
                    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                    definedAliases = [ "@hm" ];
                  };
                  "Home-Manager Docs" = {
                    urls = [{ template = "https://rycee.gitlab.io/home-manager/options.html"; }];
                    definedAliases = [ "@hm-docs" ];
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
                  "YouTube" = {
                    urls = [{
                      template = "https://www.youtube.com/search";
                      params = [
                        { name = "type"; value = "search"; }
                        { name = "q"; value = "{searchTerms}"; }
                      ];
                    }];
                    definedAliases = [ "@yt" ];
                  };
                  "DuckDuckGo" = {
                    name = "DuckDuckGo";
                    keyword = "@ddg";
                    search = "https://duckduckgo.com/?q={searchTerms}";
                  };
                  "Sourcegraph" =
                    let
                      # search repos without nixos and home-manager repo
                      nix-search = "context:global+lang:Nix+-repo:^github\.com/NixOS/nixpkgs$+-repo:^github\.com/nix-community/home-manager$";
                    in
                    {
                      urls = [{
                        template = "https://www.sourcegraph.com/";
                        params = [
                          { name = "type"; value = "search"; }
                          { name = "q"; value = "${nix-search}+{searchTerms}"; }
                        ];
                      }];
                      definedAliases = [ "@sc" ];
                    };
                  "Bing".metaData = {
                    hidden = false;
                    alias = "@b";
                  };
                  "Google".metaData.alias = "@g";
                  "Wikipedia".metaData.alias = "@wiki";
                };
                default = "Google";
                force = true;
              };
              bookmarks = [
                {
                  name = "CS (UBL)";
                  url = "https://github.com/Universidade-Livre/ciencia-da-computacao";
                }
                {
                  name = "CS (Wyden)";
                  url = "https://estudante.wyden.com.br/disciplinas";
                }
                {
                  name = "Data Structures Course (FM)";
                  url = "https://frontendmasters.com/courses/algorithms/";
                }
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
                      name = "Nix Package";
                      keyword = "np";
                      tags = [ "nix" ];
                      url = "https://search.nixos.org/packages?channel=unstable";
                    }
                    {
                      name = "Nix Options";
                      keyword = "no";
                      tags = [ "nix" ];
                      url = "https://search.nixos.org/options?channel=unstable";
                    }
                    {
                      name = "wiki";
                      tags = [ "wiki" "nix" ];
                      keyword = "nw";
                      url = "https://wiki.nixos.org/wiki/Linux_kernel";
                    }
                    {
                      name = "home-manager options";
                      tags = [ "wiki" "nix" "home-manager" ];
                      keyword = "hm";
                      url = "https://home-manager-options.extranix.com/";
                    }
                    {
                      name = "Home-Manager";
                      keyword = "hm-doc";
                      tags = [ "wiki" "nix" "home-manager" ];
                      url = "https://nix-community.github.io/home-manager/options.xhtml";
                    }
                    {
                      name = "Mynixos";
                      tags = [ "wiki" "nix" "nix-modules" ];
                      url = "https://mynixos.com/";
                    }
                  ];
                }
                {
                  name = "GitHub";
                  keyword = "gh";
                  url = "https://github.com";
                }
                {
                  name = "GitLab";
                  keyword = "gl";
                  url = "https://gitlab.com";
                }
                {
                  name = "SourceHut";
                  keyword = "sh";
                  url = "https://git.sr.ht";
                }
              ];
            };
          };
        };
    };

    home = {
      sessionVariables = {
        # DEFAULT_BROWSER = "${_ config.programs.firefox.package}";
        DEFAULT_BROWSER = "${config.programs.firefox.package}/share/applications/firefox.desktop";
      };
    };

    xdg.mimeApps.defaultApplications =
      let
        browser = "${config.programs.firefox.package}/share/applications/firefox.desktop";
      in
      {
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
