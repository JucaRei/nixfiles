{
  config,
  lib,
  pkgs,
  osConfig ? null,
  nixGLWrapper ? (x: x),
  ...
}:
let
  inherit (lib) optional optionals mkOption mkIf;
  inherit (lib.types) enum bool;
  cfg = config.system.programs.browsers.chromium;

  isNixOS = osConfig != null;
  # Declarative check on NixOS (true if VA-API packages present)
  hasVaapi =
    if isNixOS then
      lib.any (pkg: lib.hasPrefix "vaapi" (pkg.name or "") || lib.hasPrefix "libva" (pkg.name or "")) (
        osConfig.hardware.graphics.extraPackages or (osConfig.hardware.opengl.extraPackages or [ ])
      )
    else
      false; # Fallback; runtime check below for non-NixOS
in
{
  options = {
    system.programs.browsers.chromium = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable's chrome web based browser.";
      };
      version = mkOption {
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
      packages = optional (!isNixOS) pkgs.libva-utils;

      # Example: Set env var if VA-API detected (e.g., for browsers)
      sessionVariables = {
        HAS_VAAPI = if hasVaapi then "1" else "0";
      };

      # Runtime detection for non-NixOS (via activation script)
      activation.checkVaapi = lib.mkIf (!isNixOS) (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$HOME/.local/scripts"
          if vainfo --display drm 2>/dev/null | grep -q VAProfile; then
            export HAS_VAAPI=1
          else
            export HAS_VAAPI=0
          fi
          echo "export HAS_VAAPI=$HAS_VAAPI" > "$HOME/.local/scripts/vaapi-status.sh"
        ''
      );

      # Ensure Vivaldi proprietary codecs (H.264 / AAC) are fetched
      activation.setupVivaldiCodecs = lib.mkIf (cfg.version == "vivaldi") (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -e "$HOME/.local/lib/vivaldi/media-codecs-8.1/libffmpeg.so" ]; then
            ${pkgs.bash}/bin/bash "${config.programs.chromium.package}/opt/vivaldi/update-ffmpeg" --user || true
          fi
        ''
      );
    };

    programs.chromium = {
      enable = true;
      package =
        if cfg.version == "chromium" then
          nixGLWrapper pkgs.chromium
        else if cfg.version == "ungoogled-chromium" then
          nixGLWrapper pkgs.ungoogled-chromium
        else if cfg.version == "google-chrome" then
          nixGLWrapper pkgs.google-chrome
        # else if cfg.version == "opera" then
        #   (pkgs.opera.override { proprietaryCodecs = true; })
        else if cfg.version == "vivaldi" then
          nixGLWrapper pkgs.vivaldi
        # .override
        # {
        #   proprietaryCodecs = true;
        #   enableWidevine = false;
        #   # qt = "qt6";
        # }
        else if cfg.version == "edge" then
          nixGLWrapper pkgs.microsoft-edge
        else
          nixGLWrapper pkgs.brave;

      commandLineArgs = [
        "--no-default-browser-check"
        "--restore-last-session"

        # Force GPU accleration
        "--ignore-gpu-blocklist"
        # "--enable-zero-copy"
        # "--enable-unsafe-webgpu"

        # Reduce memory usage
        "--process-per-site"

        # Enable additional features
        "--enable-features=WebUIDarkMode"
        "--enable-features=WebRTCPipeWireCapturer"
      ]
      ++ optionals (config.desktop.display-servers.backend == "wayland") [
        # Force to run on Wayland
        "--ozone-platform-hint=auto"
        "--ozone-platform=wayland"
        "--enable-wayland-ime"
        "--enable-features=WaylandWindowDecorations"
      ]
      ++ optionals (hasVaapi) [
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
