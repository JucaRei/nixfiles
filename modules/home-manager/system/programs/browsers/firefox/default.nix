{ config, lib, pkgs, username, osConfig ? null, nixGLWrapper ? (x: x), ... }:
let
  inherit (lib) mkIf mkOption mkDefault mkForce;
  inherit (lib.types) bool enum;
  cfg = config.system.programs.browsers.firefox;

  sharedSettings = import ./shared.nix { inherit config lib osConfig; }
    // import ./fonts.nix { };

  isNixOS = osConfig != null;
  hasVaapi =
    if isNixOS then
      lib.any (pkg: lib.hasPrefix "vaapi" (pkg.name or "")) (osConfig.hardware.opengl.extraPackages or [ ])
    else false;
in
{
  options = {
    system.programs.browsers.firefox = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable's firefox web based browser.";
      };
      version = mkOption {
        type = enum [ "firefox" "firefox-devedition" "firefox-esr" "floorp" ];
        default = "firefox";
        description = "Choose which firefox version you want.";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      file = {
        ".mozilla/native-messaging-hosts/ff2mpv.json".source = "${pkgs.ff2mpv-rust}/lib/mozilla/native-messaging-hosts/ff2mpv.json";
      };

      sessionVariables = {
        DEFAULT_BROWSER = mkDefault "${lib.getExe config.programs.firefox.package}/share/applications/${config.programs.firefox.package}.desktop";
        MOZ_DISABLE_RDD_SANDBOX = "1"; # Disable sandbox for VA-API (security trade-off, test without first
        MOZ_ENABLE_WAYLAND = mkIf (config.desktop.display-servers.backend == "wayland") "1"; # Force Wayland mode (essential for VA-API)
      };

      packages = mkIf (!isNixOS) [ pkgs.libva-utils ];

      activation = let backup-path = "/home/${username}/.mozilla/firefox/default"; in {
        # beforeCheckLinkTargets = mkIf (cfg.browser == "firefox-esr" || cfg.browser == "firefox" || cfg.browser == "firefox-devedition") {
        beforeCheckLinkTargets = {
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

        checkVaapi = mkIf (!isNixOS) (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if vainfo --display drm 2>/dev/null | grep -q VAProfile; then
            export HAS_VAAPI=1
          else
            export HAS_VAAPI=0
          fi
          echo "export HAS_VAAPI=$HAS_VAAPI" > $HOME/.local/scripts/vaapi-status.sh
        '');
      };
    };

    programs.firefox = {
      enable = true;
      package =
        if (cfg.version == "firefox-esr") then nixGLWrapper pkgs.firefox-esr
        else if (cfg.version == "firefox") then nixGLWrapper pkgs.firefox
        else if (cfg.version == "floorp") then nixGLWrapper pkgs.floorp-bin
        else (cfg.version == "firefox-devedition") nixGLWrapper pkgs.firefox-devedition;

      policies = builtins.fromJSON (builtins.readFile ./policies.json);

      nativeMessagingHosts = with pkgs; [
        bukubrow
        # tridactyl-native
        fx-cast-bridge
        ff2mpv-rust
      ];

      profiles = {
        "${username}" = {
          isDefault = true;

          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            multi-account-containers # Installs the official extension
            # Add others like ublock-origin if desired
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

          containers = {
            work = {
              id = 1; # Unique integer >=0 within the profile
              name = "Work"; # Display name (defaults to attribute key if omitted)
              color = "red"; # Options: blue, turquoise, green, yellow, orange, red, pink, purple, toolbar
              icon = "briefcase"; # Options: briefcase, cart, circle, dollar, fence, fingerprint, gift, vacation, food, fruit, pet, tree, chill
            };
            personal = {
              id = 2;
              color = "purple";
              icon = "fingerprint";
            };
            chill = {
              id = 3;
              color = "yellow";
              icon = "chill";
            };
            shopping = {
              id = 4;
              color = "turquoise";
              icon = "cart";
            };
          };
          containersForce = true; # Recommended: Overwrites existing container config on Firefox launch (prevents symlink issues)

          settings = sharedSettings;
          search = import ./search.nix { inherit pkgs config; };
          bookmarks = import ./bookmarks.nix { };
        };
      };
    };
  };
}
