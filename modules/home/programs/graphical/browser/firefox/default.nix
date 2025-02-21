# {{ options, config, lib, pkgs, namespace, ... }:
# with lib;
# with lib.types;
# with lib.${namespace};
# let
#   cfg = config.${namespace}.programs.graphical.browser.firefox;
#   defaultSettings = {
#     "browser.aboutwelcome.enabled" = false;
#     "browser.meta_refresh_when_inactive.disabled" = true;
#     "browser.startup.homepage" = "https://www.uol.com.br";
#     "browser.bookmarks.showMobileBookmarks" = true;
#     "browser.urlbar.suggest.quicksuggest.sponsored" = false;
#     "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
#     "browser.aboutConfig.showWarning" = false;
#     "browser.ssb.enabled" = true;
#   };
# in
# {
#   options.${namespace}.programs.graphical.browser.firefox = {
#     enable = mkBoolOpt false "Whether or not to enable Firefox.";
#     # extraConfig = mkOpt str "" "Extra configuration for the user profile JS file.";
#     # userChrome = mkOpt str "" "Extra configuration for the user chrome CSS file.";
#     # settings = mkOpt attrs defaultSettings "Settings to apply to the profile.";
#   };

#   config = mkIf cfg.enable {
#     # ${namespace}.desktop.addons.firefox-nordic-theme = enabled;

#     # services.gnome.gnome-browser-connector.enable = config.${namespace}.desktop.environment.gnome.enable;

#     ${namespace} = {
#       home = {
#         # file = mkMerge [
#         #   {
#         #     ".mozilla/native-messaging-hosts/com.dannyvankooten.browserpass.json".source = "${pkgs.browserpass}/lib/mozilla/native-messaging-hosts/com.dannyvankooten.browserpass.json";
#         #   }
#         #   # (mkIf config.${namespace}.desktop.environment.gnome.enable {
#         #   #   ".mozilla/native-messaging-hosts/org.gnome.chrome_gnome_shell.json".source = "${pkgs.chrome-gnome-shell}/lib/mozilla/native-messaging-hosts/org.gnome.chrome_gnome_shell.json";
#         #   # })
#         # ];

#         extraOptions = {
#           programs.firefox = {
#             enable = true;
#             # package = pkgs.firefox;

#             nativeMessagingHosts = [
#               pkgs.browserpass
#             ]
#               # ++ optional config.${namespace}.desktop.environment.gnome.enable pkgs.gnomeExtensions.gsconnect
#             ;

#             # profiles.${config.${namespace}.user.name} = {
#             #   inherit (cfg) extraConfig userChrome settings;
#             #   id = 0;
#             #   name = config.${namespace}.user.name;
#             # };
#           };
#         };
#       };
#     };
#   };
# }
{ }
