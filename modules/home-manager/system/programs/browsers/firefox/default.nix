{
  config,
  lib,
  pkgs,
  username,
  osConfig ? null,
  nixGLWrapper ? (x: x),
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    mkForce
    ;
  inherit (lib.types) bool enum;
  cfg = config.system.programs.browsers.firefox;

  # Definição dinâmica do configPath por versão/fork:
  # - Floorp armazena perfis e configurações em ~/.floorp
  # - LibreWolf armazena perfis e configurações em ~/.librewolf
  # - Firefox, Firefox DevEdition e Firefox ESR usam ~/.mozilla/firefox
  configPath =
    if cfg.version == "floorp" then
      ".floorp"
    else if cfg.version == "librewolf" then
      ".librewolf"
    else
      ".mozilla/firefox";

  binName =
    if cfg.version == "floorp" then
      "floorp"
    else if cfg.version == "librewolf" then
      "librewolf"
    else if cfg.version == "firefox-devedition" then
      "firefox-devedition"
    else if cfg.version == "firefox-esr" then
      "firefox-esr"
    else
      "firefox";

  sharedSettings =
    import ./shared.nix {
      inherit config lib osConfig;
      inherit (cfg) version;
    }
    // import ./fonts.nix { };

  selectedPackage =
    if (cfg.version == "firefox-esr") then
      pkgs.firefox-esr
    else if (cfg.version == "floorp") then
      (pkgs.floorp-bin or pkgs.floorp)
    else if (cfg.version == "firefox-devedition") then
      pkgs.firefox-devedition
    else if (cfg.version == "librewolf") then
      pkgs.librewolf
    else
      pkgs.firefox;

  # Scripts auxiliares para forçar GPU específica via terminal ou menu contextual:
  # O binário padrão ${binName} já executa automaticamente com a prioridade inteligente:
  # NVIDIA (se detectada) -> Intel -> AMD -> Hardware padrão via nixGLWrapper.
  nvOffloadScript = pkgs.writeShellScriptBin "${binName}-nvidia" ''
    # Injeta diretórios dedicados do driver proprietário NVIDIA do host (sem libc do Debian)
    for nv_dir in /usr/lib/x86_64-linux-gnu/nvidia/current /usr/lib64/nvidia /usr/lib/nvidia; do
      if [ -d "$nv_dir" ]; then
        export LD_LIBRARY_PATH="$nv_dir''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      fi
    done

    # Arquivos ICD do EGL e Vulkan para NVIDIA (evita que o GLVND fique restrito ao Mesa)
    for _egl in /usr/share/glvnd/egl_vendor.d/10_nvidia.json /etc/glvnd/egl_vendor.d/10_nvidia.json /usr/lib/x86_64-linux-gnu/nvidia/current/10_nvidia.json; do
      if [ -f "$_egl" ]; then
        export __EGL_VENDOR_LIBRARY_FILENAMES="$_egl:/usr/share/glvnd/egl_vendor.d/50_mesa.json''${__EGL_VENDOR_LIBRARY_FILENAMES:+:$__EGL_VENDOR_LIBRARY_FILENAMES}"
        break
      fi
    done
    for _vk in /usr/share/vulkan/icd.d/nvidia_icd.json /etc/vulkan/icd.d/nvidia_icd.json; do
      if [ -f "$_vk" ]; then
        export VK_ICD_FILENAMES="$_vk''${VK_ICD_FILENAMES:+:$VK_ICD_FILENAMES}"
        break
      fi
    done

    # Aceleração de vídeo NVDEC via nvidia-vaapi-driver
    if [ -f "${pkgs.nvidia-vaapi-driver}/lib/dri/nvidia_drv_video.so" ]; then
      export LIBVA_DRIVER_NAME=nvidia
      export NVD_BACKEND=direct
      export MOZ_DISABLE_RDD_SANDBOX=1
      export LIBVA_DRIVERS_PATH="${pkgs.nvidia-vaapi-driver}/lib/dri''${LIBVA_DRIVERS_PATH:+:$LIBVA_DRIVERS_PATH}"
    fi

    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    export MOZ_X11_EGL=1

    exec ${binName} "$@"
  '';

  intelOffloadScript = pkgs.writeShellScriptBin "${binName}-intel" ''
    export FORCE_INTEL=1
    export __NV_PRIME_RENDER_OFFLOAD=0
    exec ${binName} "$@"
  '';
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
          "librewolf"
        ];
        default = "firefox";
        description = "Choose which firefox version you want.";
      };
      preferNvidia = mkOption {
        type = bool;
        default = false;
        description = "Prefer NVIDIA dGPU via PRIME offload for browser rendering and video acceleration.";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [
        pkgs.nvidia-vaapi-driver
        nvOffloadScript
        intelOffloadScript
      ];

      file = {
        ".mozilla/native-messaging-hosts/ff2mpv.json".source =
          "${pkgs.ff2mpv-rust}/lib/mozilla/native-messaging-hosts/ff2mpv.json";
      }
      // lib.optionalAttrs (cfg.version == "librewolf") {
        ".librewolf/librewolf.overrides.cfg".text = ''
          // LibreWolf Overrides - Preservar abas e sessoes ao fechar
          defaultPref("browser.startup.page", 3);
          defaultPref("privacy.sanitize.sanitizeOnShutdown", false);
          defaultPref("privacy.clearOnShutdown.history", false);
          defaultPref("privacy.clearOnShutdown.sessions", false);
          defaultPref("privacy.clearOnShutdown.cookies", false);
          defaultPref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", false);
          defaultPref("privacy.clearOnShutdown_v2.browsingHistoryAndDownloads", false);
          defaultPref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);

          // Permitir download de temas e extensões (evitar "connection failure" por OCSP)
          defaultPref("security.OCSP.require", false);

          // Largura mínima de abas normal para evitar bordas sobrepondo
          defaultPref("browser.tabs.tabMinWidth", 76);

          // Transparência ARGB para evitar cantos brancos quadrados em popups no X11
          defaultPref("mozilla.widget.use-argb-visuals", true);

          // Desbloquear API de instalação de extensões e temas na loja da Mozilla
          defaultPref("privacy.resistFingerprinting.block_mozAddonManager", false);
        '';
      };

      sessionVariables = {
        MOZ_DISABLE_RDD_SANDBOX = "1"; # Disable sandbox for VA-API (security trade-off, test without first)
        MOZ_ENABLE_WAYLAND = mkIf (config.desktop.display-servers.backend == "wayland") "1"; # Force Wayland mode (essential for VA-API)
        MOZ_X11_EGL = mkIf (config.desktop.display-servers.backend == "x11") "1"; # Force EGL on X11 (essential for VA-API DMABuf on X11)
      };
      # NOTE: NVIDIA PRIME env vars (__NV_PRIME_RENDER_OFFLOAD, LIBVA_DRIVER_NAME=nvidia, etc.)
      # are NOT set as global sessionVariables to avoid conflicting with host-level
      # LIBVA_DRIVER_NAME (e.g. "iHD" on nitro). They are injected per-process via nvOffloadScript.

      activation = {
        beforeCheckLinkTargets = {
          after = [ ];
          before = mkForce [ "checkLinkTargets" ];
          data = mkForce ''
            for d in "$HOME/.mozilla/firefox" "$HOME/.floorp" "$HOME/.librewolf"; do
              if [ -d "$d" ]; then
                find "$d" -name "search.json.mozlz4*" -type f -exec rm -f {} + 2>/dev/null || true
              fi
            done
          '';
        };

        setupFirefoxNativeMessagingHosts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$HOME/.mozilla/native-messaging-hosts"
          for vendor in "$HOME/.floorp" "$HOME/.librewolf"; do
            mkdir -p "$vendor"
            if [ -d "$vendor/native-messaging-hosts" ] && [ ! -L "$vendor/native-messaging-hosts" ]; then
              for f in "$HOME/.mozilla/native-messaging-hosts"/*; do
                [ -e "$f" ] && ln -sf "$f" "$vendor/native-messaging-hosts/"
              done
            elif [ ! -e "$vendor/native-messaging-hosts" ]; then
              ln -sfn "$HOME/.mozilla/native-messaging-hosts" "$vendor/native-messaging-hosts"
            fi
          done
        '';
      };
    };

    xdg.desktopEntries = {
      "${binName}" = {
        name =
          if cfg.version == "librewolf" then
            "LibreWolf"
          else if cfg.version == "floorp" then
            "Floorp"
          else
            "Firefox";
        genericName = "Web Browser";
        comment = "Navegador Web" + lib.optionalString cfg.preferNvidia " (NVIDIA dGPU)";
        icon = binName;
        exec = if cfg.preferNvidia then "${binName}-nvidia %U" else "${binName} %U";
        terminal = false;
        categories = [
          "Network"
          "WebBrowser"
        ];
        mimeType = [
          "text/html"
          "text/xml"
          "application/xhtml+xml"
          "application/xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];
        actions =
          if cfg.preferNvidia then
            {
              open-intel = {
                name = "Open with Intel iGPU";
                exec = "${binName}-intel %U";
              };
            }
          else
            {
              open-nvidia = {
                name = "Open with NVIDIA dGPU";
                exec = "${binName}-nvidia %U";
              };
            };
      };
    };

    programs.firefox = {
      enable = true;
      inherit configPath;
      package = nixGLWrapper selectedPackage;

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
          search = {
            force = true;
          }
          // import ./search.nix { inherit pkgs config; };
          bookmarks = {
            force = true;
            settings = import ./bookmarks.nix;
          };
        };
      };
    };
  };
}
