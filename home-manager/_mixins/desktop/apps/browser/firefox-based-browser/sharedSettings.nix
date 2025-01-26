{ lib, ... }:
let
  inherit (lib) mkForce;
in
{
  "devtools.theme" = "dark";
  "distribution.searchplugins.defaultLocale" = "en-US";
  "general.useragent.locale" = "en-US";
  "general.useragent.compatMode.firefox" = true;
  "browser.bookmarks.showMobileBookmarks" = true;
  "browser.tabs.opentabfor.middleclick" = true;
  "browser.compactmode.show" = true;
  # "browser.uidensity" = 0; # Set UI density to normal
  "browser.uidensity" = 1; # enable compact mode
  "ui.systemUsesDarkTheme" = 1; # force dark theme
  "browser.tabs.tabMinWidth" = 16;
  "browser.tabs.firefox-view" = true; # Sync tabs across devices
  "browser.toolbars.bookmarks.visibility" = "never";
  # "browser.download.always_ask_before_handling_new_types" = true;
  # "browser.download.sanitize_non_media_extensions" = false;
  "browser.search.openintab" = false;
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
  "browser.disableResetPrompt" = false;
  "browser.download.panel.shown" = true;
  "browser.startup.homepage" = "https://www.google.com/";
  "browser.shell.checkDefaultBrowser" = mkForce false;
  "browser.shell.defaultBrowserCheckCount" = 1;

  # Enable userContent.css and userChrome.css for our theme modules
  "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
  "browser.crashReports.unsubmittedCheck.enabled" = false;
  "browser.fixup.dns_first_for_single_words" = false;
  "browser.newtab.extensionControlled" = true;
  "browser.search.update" = mkForce false;
  "browser.urlbar.suggest.bookmark" = true;
  "browser.urlbar.suggest.history" = true;
  "browser.urlbar.suggest.openpage" = false;
  "browser.tabs.warnOnClose" = false;
  # "browser.urlbar.update2.engineAliasRefresh" = true;
  "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
  "dom.disable_window_flip" = true;
  "dom.disable_window_move_resize" = false;
  "dom.event.contextmenu.enabled" = true;
  "dom.reporting.crash.enabled" = false;
  "extensions.getAddons.showPane" = false;
  "media.gmp-gmpopenh264.enabled" = true;
  "media.gmp-widevinecdm.enabled" = true;
  "media.ffmpeg.vaapi.enabled" = true; ## keep this with ff 96
  "media.rdd-ffmpeg.enabled" = true; ## keep this with ff 96
  "media.rdd-vpx.enabled" = false; ## remove on ff 96
  "media.navigator.mediadatadecoder_vpx_enabled" = true; ## remove on ff 96
  "media.ffvpx.enabled" = false;
  # disable av1, vaapi on old hardware does not support av1
  "media.av1.enabled" = false;
  "media.peerconnection.enabled" = true;
  "gfx.webrender.all" = true;
  "places.history.enabled" = true;
  "security.ssl.errorReporting.enabled" = false;
  "widget.use-xdg-desktop-portal.file-picker" = 1; # Always use XDG portals for stuff
  # "security.identityblock.show_extended_validation" = true;
  # Show more ssl cert infos
  "experiments.supported" = false;
  "experiments.enabled" = false;
  # "experiments.manifest.uri" = "";
  "datareporting.healthreport.service.enabled" = false;
  # privacy tweaks
  # "browser.contentblocking.category" = "strict";
  "intl.accept_languages" = "en-US, en";
  "javascript.use_us_english_locale" = true;
  "privacy.clearOnShutdown.cache" = false;
  "privacy.clearOnShutdown.cookies" = false;
  "privacy.clearOnShutdown.downloads" = false;
  "privacy.clearOnShutdown.formdata" = false;
  "privacy.clearOnShutdown.history" = false;
  "privacy.clearOnShutdown.offlineApps" = true;
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
  "permissions.default.desktop-notification" = 0;
  "permissions.default.xr" = 2; # Virtual Reality
  # "browser.discovery.enabled" = false;
  "datareporting.healthreport.uploadEnabled" = false;
  "datareporting.policy.dataSubmissionEnabled" = false;
  "app.shield.optoutstudies.enabled" = false;
  # "app.normandy.enabled" = false;
  # "app.normandy.api_url" = "";

  # Tweaks from archwiki
  "browser.cache.disk.enable" = true;
  "browser.cache.memory.enable" = true;
  # "browser.cache.memory.capacity" = -1;
  "browser.aboutConfig.showWarning" = false;
  "browser.preferences.defaultPerformanceSettings.enabled" = false;
  "middlemouse.paste" = false;

  # (copied into here because home-manager already writes to user.js)
  "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # Enable customChrome.cs
  "svg.context-properties.content.enabled" = true; # Enable SVG context-propertes

  # Harden SSL
  # "security.ssl.require_safe_negotiation" = true;

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
}
