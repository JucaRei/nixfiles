{ pkgs, config, lib, username, osConfig, ... }:
let
  inherit (lib) mkOption mkIf mkForce types getExe;
  cfg = config.programs.graphical.apps.browser.firefox;
  # inherit (pkgs.nur.repos.rycee) firefox-addons;

  sharedSettings = import ./sharedSettings.nix { inherit osConfig lib; } //
    import ./fonts.nix { };
  custom-policies = import ./policies.nix;
  # floorpconf = import ./floop-config.nix { inherit osConfig lib; };

  defaultFirefox = if (cfg.browser == "firefox" || cfg.browser == "firefox-devedition" || cfg.browser == "firefox-esr") then true else false;
in
{

  options = {
    programs.graphical.apps.browser.firefox = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable a firefox based browser.";
      };
      version = mkOption {
        type = types.enum [ "firefox" "firefox-devedition" "firefox-esr" ];
        default = "firefox";
        description = "The firefox browser version to use.";
      };
      disableWayland = mkOption {
        type = types.bool;
        default = mkIf (!config.features.isWayland.enable);
        description = "Disable Wayland support.";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package =
        if (cfg.browser == "firefox-esr") then
          pkgs.firefox-esr
        else if (cfg.browser == "firefox") then
          pkgs.firefox
        else if (cfg.browser == "firefox" && config.features.isWayland.enable) then
          pkgs.firefox-wayland
        else
          (cfg.browser == "firefox-devedition")
            pkgs.firefox-devedition

        # else if (cfg.browser == "librewolf") then
        #   pkgs.librewolf
        # else if (cfg.browser == "floorp") then
        #   pkgs.floorp-unwrapped.override { pipewireSupport = true; }
        # else (cfg.browser == "floorp") pkgs.floorp;
        # else
        #   pkgs.waterfox;
      ;

      policies = mkIf defaultFirefox custom-policies;

      nativeMessagingHosts = mkIf defaultFirefox (with pkgs; [
        bukubrow
        tridactyl-native
        fx-cast-bridge
      ]);

      profiles = {
        default = {
          id = 0;
          # settings = if (cfg.browser == "floop") then floorpconf else sharedSettings;
          settings = sharedSettings;
          isDefault = true;
          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            ## Install extensions from NUR
            multi-account-containers
            ublock-origin
            return-youtube-dislikes
            don-t-fuck-with-paste
            search-by-image

            # (buildFirefoxXpiAddon {
            #   pname = "bypass-paywalls";
            #   addonId = "magnolia@12.34";
            #   version = "master";
            #   url = "https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass_paywalls_clean-3.9.0.0.xpi&inline=false&commit=0532b9830d43992b2f2e63e5335d58d1a8681704";
            #   sha256 = "sha256-DLhryk7rdglguLEUscvZgveC2adyTDTyC0mp2eTuvBs=";
            #   meta = with lib; {
            #     description = "A paywall bypasser";
            #     license = licenses.mit;
            #     platforms = platforms.all;
            #   };
            # })
          ];
          search = import ./search.nix { inherit pkgs config; };
          bookmarks = import ./bookmarks.nix;
        };
      };


    };
    # force brave to use wayland - https://skerit.com/en/make-electron-applications-use-the-wayland-renderer
    home = {
      packages = with pkgs; [
        # iosevka-comfy.comfy
        # merriweather
        roboto
      ];
      sessionVariables = {
        DEFAULT_BROWSER = "${getExe config.programs.graphical.apps.browser.firefox.version}/share/applications/${config.programs.graphical.apps.browser.firefox.version}.desktop";
      };

      file = mkIf defaultFirefox {
        ".mozilla/native-messaging-hosts/ff2mpv.json".source = "${pkgs.ff2mpv-rust}/lib/mozilla/native-messaging-hosts/ff2mpv.json";
      };

      activation =
        let
          backup-path = "/home/${username}/.mozilla/firefox/default";
        in
        {
          beforeCheckLinkTargets = mkIf (cfg.browser == "firefox-esr" || cfg.browser == "firefox" || cfg.browser == "firefox-devedition") {
            after = [ ];
            before = mkForce [ "checkLinkTargets" ];
            data = mkForce ''
              if [ -f "${backup-path}/search.json.mozlz4.home-manager.backup" ]; then
                rm "${backup-path}/search.json.mozlz4.home-manager.backup"
              fi

              if [ -f "${backup-path}/search.json.mozlz4" ]; then
                rm "${backup-path}/search.json.mozlz4"
              fi
            '';
          };
        };
    };
  };
}

# "librewolf" "floorp" "waterfox"
