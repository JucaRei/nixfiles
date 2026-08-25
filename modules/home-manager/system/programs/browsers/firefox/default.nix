{
  config,
  lib,
  pkgs,
  username,
  osConfig ? null,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    mkDefault
    mkForce
    ;
  inherit (lib.types) bool enum;
  cfg = config.system.programs.browsers.firefox;

  sharedSettings = import ./shared.nix { inherit config lib osConfig; } // import ./fonts.nix { };

  isNixOS = osConfig != null;
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
        type = enum [
          "firefox"
          "firefox-devedition"
          "firefox-esr"
          "floorp"
        ];
        default = "firefox";
        description = "Choose which firefox version you want.";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      file = {
        ".mozilla/native-messaging-hosts/ff2mpv.json".source =
          "${pkgs.ff2mpv-rust}/lib/mozilla/native-messaging-hosts/ff2mpv.json";
      };

      sessionVariables = {
        DEFAULT_BROWSER = mkDefault "${lib.getExe config.programs.firefox.package}/share/applications/${config.programs.firefox.package}.desktop";
        MOZ_DISABLE_RDD_SANDBOX = "1"; # Disable sandbox for VA-API (security trade-off, test without first
        MOZ_ENABLE_WAYLAND = mkIf (config.desktop.display-servers.backend == "wayland") "1"; # Force Wayland mode (essential for VA-API)
      };

      packages = mkIf (!isNixOS) [ pkgs.libva-utils ];

      activation = {
        beforeCheckLinkTargets = {
          after = [ ];
          before = mkForce [ "checkLinkTargets" ];
          data = mkForce ''
            find "$HOME/.mozilla/firefox" -name "search.json.mozlz4*" -type f -exec rm -f {} + 2>/dev/null || true
          '';
        };

          checkVaapi = mkIf (!isNixOS) (
            lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              if vainfo --display drm 2>/dev/null | grep -q VAProfile; then
                export HAS_VAAPI=1
              else
                export HAS_VAAPI=0
              fi
              echo "export HAS_VAAPI=$HAS_VAAPI" > $HOME/.local/scripts/vaapi-status.sh
            ''
          );
        };
    };

    programs.firefox = {
      enable = true;
      configPath = ".mozilla/firefox";
      package =
        if (cfg.version == "firefox-esr") then
          pkgs.firefox-esr
        else if (cfg.version == "floorp") then
          pkgs.floorp-bin
        else if (cfg.version == "firefox-devedition") then
          pkgs.firefox-devedition
        else
          pkgs.firefox;

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

          extensions = {
            packages = with pkgs.nur.repos.rycee.firefox-addons; [
              multi-account-containers # Installs the official extension
              # Add others like ublock-origin if desired
              ublock-origin
              return-youtube-dislikes
              don-t-fuck-with-paste
              search-by-image
            ];
          };

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
          search = { force = true; } // import ./search.nix { inherit pkgs config; };
          bookmarks = {
            force = true;
            settings = import ./bookmarks.nix;
          };
        };
      };
    };
  };
}
