{
  AutofillAddressEnabled = false;
  AutofillCreditCardEnabled = false;
  Cookies = {
    AcceptThirdParty = "from-visited";
    # Behavior = "reject-tracker";
    # BehaviorPrivateBrowsing = "reject-tracker";
    # RejectTracker = true;
  };
  DisableAppUpdate = true;
  DisableDefaultBrowserAgent = true;
  DisableFormHistory = false;
  DisablePocket = true;
  DisableSetDesktopBackground = false;
  DisplayBookmarksToolbar = "never";
  DisplayMenuBar = "default-off";
  DNSOverHTTPS = {
    Enabled = false;
  };
  DisableProfileImport = false;
  FirefoxHome = {
    Highlights = false;
    Locked = false;
    Pocket = false;
    Snippets = false;
    Search = true;
    SponsporedPocket = false;
    SponsporedTopSites = false;
    TopSites = false;
  };
  FirefoxSuggest = {
    WebSuggestions = true;
    SponsoredSuggestions = false;
    ImproveSuggest = false;
    Locked = true;
  };
  # FlashPlugin = {
  #   Default = false;
  # };
  Homepage = {
    Locked = false;
    StartPage = "previous-session";
  };
  NetworkPrediction = true;
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
  # CaptivePortal = false;
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
  PDFjs = {
    Enabled = true;
    EnablePermissions = false;
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

  ExtensionSettings = {
    # "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
    # Check about:support for extension/add-on ID strings.
    # Valid strings for installation_mode are "allowed", "blocked",
    # "force_installed" and "normal_installed".
    # ublock-origin:
    # "uBlock0@raymondhill.net" = {
    #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
    #   installation_mode = "force_installed";
    # };

    # simple-translate:
    "simple-translate@sienori" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/simple-translate/latest.xpi";
      installation_mode = "force_installed";
    };

    # midnight-lizard:
    "{8fbc7259-8015-4172-9af1-20e1edfbbd3a}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/midnight-lizard-quantum/latest.xpi";
      installation_mode = "force_installed";
    };

    # Music Mode for YouTube™:
    "{e960c19a-b3ce-477c-8a0d-d82959225dee}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/music-mode-for-youtube/latest.xpi";
      installation_mode = "force_installed";
    };

    # catppuccin mocha mauve:
    "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/catppuccin-mocha-mauve-git/latest.xpi";
      installation_mode = "force_installed";
    };
  };
}
