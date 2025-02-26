{ pkgs, config, lib, username, osConfig, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.desktop.apps.browser.firefox-based-browser;
  # inherit (pkgs.nur.repos.rycee) firefox-addons;

  sharedSettings = import ./sharedSettings.nix { inherit osConfig lib; };
  custom-policies = import ./policies.nix;
  floorpconf = import ./floop-config.nix { inherit osConfig lib; };

  defaultFirefox = if (cfg.browser == "firefox" || cfg.browser == "firefox-devedition" || cfg.browser == "firefox-esr") then true else false;
in
{

  options = {
    desktop.apps.browser.firefox-based-browser = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable a firefox based browser.";
      };
      browser = mkOption {
        type = types.enum [ "firefox" "firefox-devedition" "firefox-esr" "librewolf" "floorp" "waterfox" ];
        default = "firefox-esr";
        description = "The browser to use.";
      };
      disableWayland = mkOption {
        type = types.bool;
        default = mkIf (!config.features.isWayland.enable);
        description = "Disable Wayland support.";
      };
    };
  };

  config = mkIf cfg.enable {
    # home.packages =
    #   optional (cfg.browser == "vivaldi") pkgs.vivaldi-ffmpeg-codecs;
    programs.firefox =
      # let
      #   defaultFirefox = if (cfg.browser == "firefox" || cfg.browser == "firefox-devedition" || cfg.browser == "firefox-esr") then true else false;
      # in
      {
        enable = true;
        package =
          if (cfg.browser == "firefox-esr") then
            pkgs.firefox-esr
          else if (cfg.browser == "firefox") then
            pkgs.firefox
          else if (cfg.browser == "firefox" && config.features.isWayland.enable) then
            pkgs.firefox-wayland
          else if (cfg.browser == "firefox-devedition") then
            pkgs.firefox-devedition
          else if (cfg.browser == "librewolf") then
            pkgs.librewolf
          # else if (cfg.browser == "floorp") then
          #   pkgs.floorp-unwrapped.override { pipewireSupport = true; }
          else (cfg.browser == "floorp") pkgs.floorp;
        # else
        #   pkgs.waterfox;

        policies = mkIf defaultFirefox custom-policies;

        nativeMessagingHosts = mkIf defaultFirefox (with pkgs; [
          bukubrow
          tridactyl-native
          fx-cast-bridge
        ]);

        profiles = {
          # ${username} = {
          default = {
            id = 0;
            settings = if (cfg.browser == "floop") then floorpconf else sharedSettings;
            isDefault = true;
            extensions = with pkgs.nur.repos.rycee.firefox-addons; [
              ## Install extensions from NUR
              #   decentraleyes
              ublock-origin
              return-youtube-dislikes
              don-t-fuck-with-paste
              # midnight-lizard
              # noscript
              search-by-image
              # clearurls
              # sponsorblock
              # darkreader
              # h264ify
              # df-youtube
            ];
            search = import ./search.nix { inherit pkgs config; };
            bookmarks = import ./bookmarks.nix;
          };
        };


      };
    # force brave to use wayland - https://skerit.com/en/make-electron-applications-use-the-wayland-renderer
    home = {
      sessionVariables = {
        DEFAULT_BROWSER = "${config.desktop.apps.browser.firefox-based-browser.browser}/share/applications/${config.desktop.apps.browser.firefox-based-browser.browser}.desktop";
      };

      file = mkIf defaultFirefox {
        ".mozilla/native-messaging-hosts/ff2mpv.json".source = "${pkgs.ff2mpv}/lib/mozilla/native-messaging-hosts/ff2mpv.json";
      };

      activation =
        let
          backup-path = "/home/${username}/.mozilla/firefox/default";
        in
        {
          beforeCheckLinkTargets = mkIf (cfg.browser == "firefox-esr" || cfg.browser == "firefox" || cfg.browser == "firefox-devedition") {
            after = [ ];
            before = [ "checkLinkTargets" ];
            data = ''
              if [ -f "${backup-path}/search.json.mozlz4.hm-backup" ]; then
                rm "${backup-path}/search.json.mozlz4.hm-backup"
              fi
            '';
          };
        };
    };
  };
}
