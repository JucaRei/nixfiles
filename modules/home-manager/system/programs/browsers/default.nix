{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption mkDefault mkMerge types;

  cfg = config.system.programs.browsers;
  cfgFf = cfg.firefox;
  cfgCr = cfg.chromium;

  # Lookup tables: versão → { desktop, bin }
  firefoxMap = {
    firefox           = { desktop = "firefox.desktop";             bin = "firefox"; };
    firefox-devedition = { desktop = "firefox-devedition.desktop"; bin = "firefox-devedition"; };
    firefox-esr       = { desktop = "firefox-esr.desktop";         bin = "firefox-esr"; };
    floorp            = { desktop = "floorp.desktop";              bin = "floorp"; };
  };

  chromiumMap = {
    chromium            = { desktop = "chromium-browser.desktop";  bin = "chromium"; };
    ungoogled-chromium  = { desktop = "chromium-browser.desktop";  bin = "chromium"; };
    google-chrome       = { desktop = "google-chrome.desktop";     bin = "google-chrome-stable"; };
    brave               = { desktop = "brave-browser.desktop";     bin = "brave"; };
    vivaldi             = { desktop = "vivaldi-stable.desktop";    bin = "vivaldi"; };
    edge                = { desktop = "microsoft-edge.desktop";    bin = "microsoft-edge"; };
  };

  ffInfo  = firefoxMap.${cfgFf.version or "firefox"};
  crInfo  = chromiumMap.${cfgCr.version or "brave"};

  # Determina o navegador padrão
  chosen =
    if cfg.default == "none"     then null
    else if cfg.default == "firefox"  then (if cfgFf.enable then "firefox" else null)
    else if cfg.default == "chromium" then (if cfgCr.enable then "chromium" else null)
    else # "auto"
      if      cfgFf.enable then "firefox"
      else if cfgCr.enable then "chromium"
      else null;

  activeDesktop = if chosen == "firefox" then ffInfo.desktop
                  else if chosen == "chromium" then crInfo.desktop
                  else null;

  activeBin = if chosen == "firefox" then ffInfo.bin
              else if chosen == "chromium" then crInfo.bin
              else null;

  mimeTypes = [
    "text/html"
    "text/xml"
    "application/xhtml+xml"
    "application/xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/about"
    "x-scheme-handler/unknown"
  ] ++ lib.optional (chosen == "chromium") "x-scheme-handler/chrome";
in
{
  imports = [
    ./firefox
    ./chrome
  ];

  options.system.programs.browsers = {
    default = mkOption {
      type = types.enum [ "auto" "firefox" "chromium" "none" ];
      default = "auto";
      description = ''
        Navegador padrão do sistema (x-scheme-handler/http, text/html, etc).
        "auto" seleciona o primeiro navegador habilitado (firefox > chromium).
      '';
    };

    activeDesktopFile = mkOption {
      type = types.nullOr types.str;
      default = activeDesktop;
      readOnly = true;
      description = "Arquivo .desktop do navegador padrão ativo.";
    };

    activeBin = mkOption {
      type = types.nullOr types.str;
      default = activeBin;
      readOnly = true;
      description = "Binário executável do navegador padrão ativo.";
    };
  };

  config = mkMerge [
    # Fontes e codecs auxiliares
    (mkIf (cfgFf.enable || cfgCr.enable) {
      home.packages = with pkgs; [
        nerd-fonts.martian-mono
        lato
        abel
        ffmpeg
      ];
    })

    # Associações MIME e variáveis de sessão
    (mkIf (activeDesktop != null) {
      xdg.mimeApps = {
        defaultApplications =
          builtins.listToAttrs (map (mime: { name = mime; value = mkDefault activeDesktop; }) mimeTypes);
        associations.added =
          builtins.listToAttrs (map (mime: { name = mime; value = activeDesktop; }) mimeTypes);
      };

      home.sessionVariables = {
        BROWSER = mkDefault activeBin;
        DEFAULT_BROWSER = mkDefault activeBin;
      };
    })
  ];
}
