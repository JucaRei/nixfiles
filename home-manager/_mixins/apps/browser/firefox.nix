{ pkgs, config, lib, params, inputs, nur, ... }:
with lib;
let
  inherit (pkgs.nur.repos.rycee) firefox-addons;

  csshacks = pkgs.fetchFromGitHub {
    owner = "MrOtherGuy";
    repo = "firefox-csshacks";
    rev = "1ff9383984632fe91b8466730679e019de13c745";
    sha256 = "sha256-KmkiSpxzlsPBWoX51o27l+X1IEh/Uv8RMkihGRxg98o=";
  };

  # ifDefault = lib.mkIf (builtins.elem params.browser [ "firefox" ]);

  sharedSettings = {
    policies = {
      FirefoxHome = {
        Highlights = false;
        Pocket = false;
        Snippets = false;
        SponsporedPocket = false;
        SponsporedTopSites = false;
      };
      EnableTrackingProtection = true;
    };
    # Privacy & Security Improvements
    #"browser.contentblocking.category" = "strict";
    "browser.send_pings" = false;
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
    # forces ui.systemUsesDarkTheme to false
    # "privacy.resistFingerprinting" = true;
    # "webgl.disabled" = true;

    # Disable Telemetry
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.ping-centre.telemetry" = false;
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.bhrPing.enabled" = false;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
    "toolkit.telemetry.hybridContent.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.updatePing.enabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.healthreport.service.enabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;

    # Disable Personalisation & Sponsored Content
    #"browser.discovery.enabled" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" =
      false;
    "browser.newtabpage.activity-stream.feeds.snippets" = false;

    # Disable Experiments & Studies
    "experiments.activeExperiment" = false;
    "experiments.enabled" = false;
    "experiments.supported" = false;
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
    "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
    "extensions.pocket.enabled" = false;
    "media.autoplay.enabled" = false;

    # Some privacy settings...
    "privacy.donottrackheader.enabled" = true;


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
    "browser.aboutConfig.showWarning" = false;
    "signon.rememberSignons" = false;
    #"services.sync.engine.passwords" = false;
    #"extensions.update.enabled" = false;
    #"extensions.update.autoUpdateDefault" = false;

    userChrome = builtins.concatStringsSep "\n" (builtins.map builtins.readFile [
      "${csshacks}/chrome/hide_tabs_toolbar.css"
      # Preferable, but there's too many bugs with menu dropdowns not dropping
      # up when they're at the bottom of the screen
      # "${csshacks}/chrome/navbar_below_content.css"
    ]);
  };
  # librewolf = with pkgs; wrapFirefox librewolf-unwrapped {
  firefox-gl = with pkgs.unstable; wrapFirefox firefox-unwrapped {
    nativeMessagingHosts = with pkgs; [
      bukubrow
      tridactyl-native
      fx-cast-bridge
    ]
    # ++ (with pkgs.FirefoxAddons; [
    #   youtube-nonstop
    # ])
    ++ lib.optional config.programs.mpv.enable pkgs.ff2mpv;
  };

  browser = "firefox";
  # browser = "librewolf";
in
{
  programs = {
    firefox = {
      enable = true;
      # package = pkgs.unstable.firefox;
      package = firefox-gl;
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
                urls = [{
                  template = "https://search.nixos.org/options";
                  params = [
                    { name = "type"; value = "packages"; }
                    { name = "query"; value = "{searchTerms}"; }
                  ];
                }];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@no" ];
              };
              "Nix Packages" = {
                urls = [{
                  template = "https://search.nixos.org/packages";
                  params = [
                    { name = "type"; value = "packages"; }
                    { name = "query"; value = "{searchTerms}"; }
                  ];
                }];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@np" ];
              };
              "NixOS Wiki" = {
                urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
                definedAliases = [ "@nw" ];
              };
              # "Brave" = {
              #   urls = [{
              #     template = "https://search.brave.com/search";
              #     params = [
              #       { name = "type"; value = "search"; }
              #       { name = "q"; value = "{searchTerms}"; }
              #     ];
              #   }];

              #   icon = "${config.programs.brave.package}/share/icons/hicolor/64x64/apps/brave-browser.png";
              #   definedAliases = [ "@brave" "@b" ];
              # };
              "Bing".metaData.hidden = true;
              "Google".metaData.alias = "@g";
              "Wikipedia".metaData.alias = "@wiki";
            };
            default = "Google";
            force = true;
          };
        };
        # extraPolicies = {
        #   CaptivePortal = false;
        #   DisableFirefoxStudies = true;
        #   DisablePocket = true;
        #   DisableFirefoxAccounts = true;
        #   DisableFormHistory = true;
        #   DisplayBookmarksToolbar = true;
        #   DontCheckDefaultBrowser = true;
        #   FirefoxHome = {
        #     Pocket = false;
        #     Snippets = false;
        #   };
        # };
      };
    };

    # xdg = {
    #   mime.enable = ifDefault true;
    #   mimeApps = {
    #     enable = ifDefault true;
    #     defaultApplications = ifDefault (import ./default-browser.nix "firefox");
    #   };
    # };

    # home.packages =
    #   let
    #     makeFirefoxProfileBin = args @ { profile, ... }:
    #       let
    #         name = "firefox-${profile}";
    #         scriptBin = pkgs.writeScriptBin name ''
    #           firefox -P "${profile}" --name="${name}" $@
    #         '';
    #         desktopFile = pkgs.makeDesktopItem ((removeAttrs args [ "profile" ])
    #           // {
    #           inherit name;
    #           exec = "${scriptBin}/bin/${name} %U";
    #           extraConfig.StartupWMClass = name;
    #           genericName = "Web Browser";
    #           mimeTypes = [
    #             "text/html"
    #             "text/xml"
    #             "application/xhtml+xml"
    #             "application/vnd.mozilla.xul+xml"
    #             "x-scheme-handler/http"
    #             "x-scheme-handler/https"
    #           ];
    #           categories = [ "Network" "WebBrowser" ];
    #         });
    #       in
    #       pkgs.runCommand name { } ''
    #         mkdir -p $out/{bin,share}
    #         cp -r ${scriptBin}/bin/${name} $out/bin/${name}
    #         cp -r ${desktopFile}/share/applications $out/share/applications
    #       '';
    #   in
    #   with pkgs; [
    #     (tor-browser-bundle-bin.override { pulseaudioSupport = true; })
    #     (makeFirefoxProfileBin {
    #       profile = "work";
    #       desktopName = "Firefox (Work)";
    #       icon = "firefox";
    #     })
    #   ];
  };
  home = {
    sessionVariables = {
      DEFAULT_BROWSER = "${firefox-gl}/bin/${browser}";
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
}
