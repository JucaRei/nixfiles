{ config, lib, pkgs, osConfig ? null, nixGLWrapper ? (x: x), ... }:
let
  inherit (lib) optional mkOption mkIf;
  inherit (lib.types) enum bool;
  cfg = config.system.programs.browsers.chromium;

  isNixOS = osConfig != null;
  # Declarative check on NixOS (true if VA-API packages present)
  hasVaapi =
    if isNixOS then
      lib.any (pkg: lib.hasPrefix "vaapi" (pkg.name or "") || lib.hasPrefix "libva" (pkg.name or "")) (osConfig.hardware.graphics.extraPackages or (osConfig.hardware.opengl.extraPackages or [ ]))
    else false; # Fallback; runtime check below for non-NixOS
in
{
  options = {
    system.programs.browsers.chromium = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable's chrome web based browser.";
      };
      version = {
        type = enum [
          "chromium"
          "ungoogled-chromium"
          "google-chrome"
          "brave"
          "vivaldi"
          "edge"
          # "opera"
        ];
        default = "brave";
        description = "Choose which chromium version you want.";
      };
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = optional (cfg.version == "vivaldi") pkgs.vivaldi-ffmpeg-codecs
        ++ optional (!isNixOS) [ pkgs.libva-utils ];

      # Example: Set env var if VA-API detected (e.g., for browsers)
      sessionVariables = {
        HAS_VAAPI = if hasVaapi then "1" else "0";
      };

      # Runtime detection for non-NixOS (via activation script)
      activation.checkVaapi = lib.mkIf (!isNixOS) (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if vainfo --display drm 2>/dev/null | grep -q VAProfile; then
          export HAS_VAAPI=1
        else
          export HAS_VAAPI=0
        fi
        echo "export HAS_VAAPI=$HAS_VAAPI" > $HOME/.local/scripts/vaapi-status.sh
      '');
    };

    programs.chromium = {
      enable = true;
      package =
        if cfg.browser == "chromium" then nixGLWrapper pkgs.chromium
        else if cfg.browser == "ungoogled-chromium" then nixGLWrapper pkgs.ungoogled-chromium
        else if cfg.browser == "google-chrome" then nixGLWrapper pkgs.google-chrome
        # else if cfg.browser == "opera" then
        #   (pkgs.opera.override { proprietaryCodecs = true; })
        else if cfg.browser == "vivaldi" then nixGLWrapper pkgs.vivaldi
        # .override
        # {
        #   proprietaryCodecs = true;
        #   enableWidevine = false;
        #   # qt = "qt6";
        # }
        else if cfg.browser == "edge" then nixGLWrapper pkgs.microsoft-edge
        else nixGLWrapper pkgs.brave;

      commandLineArgs = [
        "--no-default-browser-check"
        "--restore-last-session"

        # Force GPU accleration
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
        # "--enable-unsafe-webgpu"

        # Reduce memory usage
        "--process-per-site"

        # Enable additional features
        "--enable-features=WebUIDarkMode"
        "--enable-features=WebRTCPipeWireCapturer"
        "--enable-features=UseOzonePlatform"
      ] ++ mkIf (config.desktop.display-servers.backend == "wayland") [
        # Force to run on Wayland
        "--ozone-platform-hint=auto"
        "--ozone-platform=wayland"
        "--enable-wayland-ime"
        "--enable-features=WaylandWindowDecorations"
      ] ++ mkIf (hasVaapi) [
        "--enable-features=VaapiVideoDecodeLinuxGL"
        "--enable-features=VaapiVideoDecoder"
      ];

      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "ibplnjkanclpjokhdolnendpplpjiace" # simple translate
        "hpcmeljpfhclmddogcblpfenipkdbdfh" # Tokyo Night Storm
        "pbnndmlekkboofhnbonilimejonapojg" # Midnight Lizard
      ];

      nativeMessagingHosts = with pkgs; [
        bukubrow
        ff2mpv-rust
      ];
    };
  };
}
