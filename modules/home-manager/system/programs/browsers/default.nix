{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  inherit (lib)
    mkIf
    mkDefault
    mkMerge
    ;

  isNixOS = osConfig != null;

  cfg = config.system.programs.browsers;
  cfgFf = cfg.firefox;
  cfgCr = cfg.chromium;

  # Lookup tables: versão → { desktop, bin }
  firefoxMap = {
    firefox = {
      desktop = "firefox.desktop";
      bin = "firefox";
    };
    firefox-devedition = {
      desktop = "firefox-devedition.desktop";
      bin = "firefox-devedition";
    };
    firefox-esr = {
      desktop = "firefox-esr.desktop";
      bin = "firefox-esr";
    };
    floorp = {
      desktop = "floorp.desktop";
      bin = "floorp";
    };
    librewolf = {
      desktop = "librewolf.desktop";
      bin = "librewolf";
    };
  };

  chromiumMap = {
    chromium = {
      desktop = "chromium-browser.desktop";
      bin = "chromium";
    };
    ungoogled-chromium = {
      desktop = "chromium-browser.desktop";
      bin = "chromium";
    };
    google-chrome = {
      desktop = "google-chrome.desktop";
      bin = "google-chrome-stable";
    };
    brave = {
      desktop = "brave-browser.desktop";
      bin = "brave";
    };
    vivaldi = {
      desktop = "vivaldi-stable.desktop";
      bin = "vivaldi";
    };
    edge = {
      desktop = "microsoft-edge.desktop";
      bin = "microsoft-edge";
    };
  };

  ffInfo = firefoxMap.${cfgFf.version or "firefox"};
  crInfo = chromiumMap.${cfgCr.version or "brave"};

  # Determina o navegador padrão
  chosen =
    if cfg.default == "none" then
      null
    else if cfg.default == "firefox" then
      (if cfgFf.enable then "firefox" else null)
    else if cfg.default == "chromium" then
      (if cfgCr.enable then "chromium" else null)
    # "auto"
    else if cfgFf.enable then
      "firefox"
    else if cfgCr.enable then
      "chromium"
    else
      null;

  activeDesktop =
    if chosen == "firefox" then
      ffInfo.desktop
    else if chosen == "chromium" then
      crInfo.desktop
    else
      null;

  activeBin =
    if chosen == "firefox" then
      ffInfo.bin
    else if chosen == "chromium" then
      crInfo.bin
    else
      null;

  mimeTypes = [
    "text/html"
    "text/xml"
    "application/xhtml+xml"
    "application/xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/about"
    "x-scheme-handler/unknown"
  ]
  ++ lib.optional (chosen == "chromium") "x-scheme-handler/chrome";
in
{
  imports = [
    ./firefox
    ./chrome
    ./psd.nix
  ];

  options.system.programs.browsers = {
    default =
      lib.my.mkEnum
        [
          "auto"
          "firefox"
          "chromium"
          "none"
        ]
        "auto"
        ''
          Navegador padrão do sistema (x-scheme-handler/http, text/html, etc).
          "auto" seleciona o primeiro navegador habilitado (firefox > chromium).
        '';

    activeBin =
      lib.my.mkReadOnly (lib.types.nullOr lib.types.str) activeBin
        "Binário executável do navegador padrão ativo.";
  };

  config = mkMerge [
    # Fontes e codecs auxiliares
    (mkIf (cfgFf.enable || cfgCr.enable) {
      home.packages = with pkgs; [
        # Fonts
        nerd-fonts.fantasque-sans-mono
        lato
        fira-go
        atkinson-hyperlegible

        # Codecs
        ffmpeg
      ];
    })

    # Detecção em tempo de ativação do VA-API para navegadores em ambientes standalone (!isNixOS)
    (mkIf ((cfgFf.enable || cfgCr.enable) && !isNixOS) {
      home = {
        packages = [ pkgs.libva-utils ];

        activation.checkVaapi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$HOME/.local/scripts"
          intel_render="$(ls /dev/dri/by-path/*00:02.0-render 2>/dev/null || echo /dev/dri/renderD129)"
          if ${pkgs.libva-utils}/bin/vainfo 2>/dev/null | grep -q VAProfile || ${pkgs.libva-utils}/bin/vainfo --display drm --device "$intel_render" 2>/dev/null | grep -q VAProfile; then
            export HAS_VAAPI=1
          else
            export HAS_VAAPI=0
          fi
          echo "export HAS_VAAPI=$HAS_VAAPI" > "$HOME/.local/scripts/vaapi-status.sh"
        '';
      };
    })

    # Associações MIME e variáveis de sessão
    (mkIf (activeDesktop != null) {
      xdg.mimeApps = {
        defaultApplications = builtins.listToAttrs (
          map (mime: {
            name = mime;
            value = mkDefault activeDesktop;
          }) mimeTypes
        );
        associations.added = builtins.listToAttrs (
          map (mime: {
            name = mime;
            value = activeDesktop;
          }) mimeTypes
        );
      };

      home.sessionVariables = {
        BROWSER = mkDefault activeBin;
        DEFAULT_BROWSER = mkDefault activeBin;
      };
    })
  ];
}
