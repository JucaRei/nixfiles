{
  config,
  lib,
  pkgs,
  desktop ? null,
  nixGLWrapper ? (x: x),
  osConfig ? null,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    optionalString
    optionalAttrs
    ;
  cfg = config.system.programs.multimedia.mpv;
  isNixOS = osConfig != null;
  isNvidiaLegacy = (osConfig.hardware.graphics.cards.gpu or null) == "nvidia-legacy";
  shouldInstall = cfg.installPackage && !cfg.useSystemPackage && !cfg.useSystemPackages;

  intelExec =
    if (!shouldInstall && !isNixOS) then
      "env __GLX_VENDOR_LIBRARY_NAME=mesa mpv --player-operation-mode=pseudo-gui -- %U"
    else
      "mpv --player-operation-mode=pseudo-gui -- %U";
  nvidiaExec = "mpv-nvidia --player-operation-mode=pseudo-gui -- %U";

  # Ambientes desktop completos tradicionais (com gerenciamento de janelas próprio, não tiling)
  fullDesktopEnvironments = [
    "xfce4"
    "xfce"
    "gnome"
    "mate"
    "pantheon"
    "plasma"
    "kde"
    "cinnamon"
    "lxde"
    "lxqt"
    "deepin"
    "budgie"
    "cosmic"
  ];

  # Identifica se o ambiente é uma Window Manager (tiling/floating standalone como bspwm, hyprland, mangowm, sway, i3, etc.)
  isWM = desktop != null && !(builtins.elem desktop fullDesktopEnvironments);

  # Tipos MIME multimídia suportados pelo MPV (vídeo, áudio e playlists)
  mediaMimeTypes = import ./_mime-types.nix;

  hwPresetSection = import ./_hw-presets.nix {
    inherit cfg shouldInstall optionalString;
  };
in
{
  # Declara a opção no mesmo módulo que a implementa (padrão do repositório).
  # Segue o mesmo estilo de editors/vscode e editors/antigravity.
  options.system.programs.multimedia.mpv = {
    enable = mkEnableOption "mpv media player with custom profiles and scripts";

    installPackage = lib.my.mkBool true ''
      Se deve instalar o executável do MPV compilado via Nix/Home Manager.
      Se definido como false, o Home Manager instalará apenas as configurações (mpv.conf, input.conf, scripts e opções de hardware)
      e utilizará o binário nativo do sistema operacional hospedeiro (ex: Debian /usr/bin/mpv).
    '';

    useSystemPackage = lib.my.mkBool false ''
      Atalho conveniente: quando true, equivale a installPackage = false.
      Permite carregar apenas as configurações preservando o MPV da distro nativa.
    '';

    useSystemPackages = lib.my.mkBool false "Alias para useSystemPackage.";

    defaultNvidia = lib.my.mkBool false ''
      Se o MPV deve abrir por padrão utilizando a dGPU NVIDIA (PRIME offload / mpv-nvidia)
      no arquivo .desktop (sobrescrevendo mpv.desktop), incluindo uma ação secundária
      no menu de contexto para abrir com a iGPU Intel.
    '';

    profile =
      lib.my.mkEnum
        [
          "auto"
          "nitro"
          "legacy-nvidia"
          "legacy-nouveau"
          "low-ram"
          "software"
        ]
        (if isNvidiaLegacy then "legacy-nvidia" else "auto")
        ''
          Perfil de hardware para reprodução no MPV:
          - "auto": decodificação segura automática (vo=gpu, gpu-api=auto, hwdec=auto-safe)
          - "nitro": perfil otimizado para Intel UHD 630 + NVIDIA dGPU
          - "legacy-nvidia": perfil para GPUs legadas com driver proprietário antigo (ex: NVIDIA 340)
          - "legacy-nouveau": perfil para GPUs legadas com driver Nouveau / Mesa
          - "low-ram": perfil econômico para máquinas com pouca RAM (ex: MacBook Air 2GB)
          - "software": perfil para renderização puramente por software em VMs sem aceleração 3D
        '';

    vaapiDevice =
      lib.my.mkOpt (lib.types.nullOr lib.types.str) null
        "Dispositivo de renderização VA-API opcional (ex: /dev/dri/by-path/pci-0000:00:02.0-render).";

    hybridGraphics = lib.my.mkBool false "Habilitar suporte e ações de dGPU NVIDIA / PRIME no desktop entry e perfil [nvidia].";

    floating = lib.my.mkBool true ''
      Se o MPV deve abrir em modo flutuante (floating) em Window Managers (BSPWM, Hyprland, Sway, i3).
      Defina como false para abrir diretamente em modo tiled na grade.
    '';
  };

  config = mkIf cfg.enable {
    # Instalação do binário MPV gerenciado via Nix / nixGL (apenas se shouldInstall = true)
    programs.mpv = mkIf shouldInstall {
      enable = true;

      # nixGLWrapper envolve o binário para resolver libGL em ambientes não-NixOS.
      # Nota: mpv-unwrapped.wrapper foi removido no nixpkgs ≥ 2025-12-29.
      # Nota: programs.mpv.package e programs.mpv.scripts são mutuamente exclusivos
      # no HM. Solução: passar scripts directamente ao pkgs.mpv.override, que os
      # inclui na derivação — sem depender do wrapping do HM.
      package = nixGLWrapper (
        pkgs.mpv.override {
          mpv-unwrapped = pkgs.mpv-unwrapped.override {
            vapoursynthSupport = true;
          };
          youtubeSupport = true;
          scripts = with pkgs.mpvScripts; [
            # uosc # UI moderna (substitui o OSC builtin)
            modernz # UI moderna OSC (ModernZ)
            memo # Histórico de ficheiros recentes
            evafast # Seeking rápido com preview
            thumbfast # Thumbnails na barra de progresso
            mpv-cheatsheet-ng # Overlay de atalhos de teclado
            sponsorblock-minimal # Skip de segmentos SponsorBlock (YouTube)
          ];
        }
      );
      # Nota: scripts declarados dentro de mpv.override acima (mutuamente exclusivo com package)
    };

    # ─────────────────────────────────────────────────────────────────────────
    # Configurações XDG (arquivos de config, associações MIME e entradas desktop)
    # ─────────────────────────────────────────────────────────────────────────
    xdg = {
      configFile = {
        # mpv.conf base (configs/mpv.conf) + perfil de hardware injetado via Nix
        # O perfil [hw-preset] define as configurações de hardware e é activado no [default].
        "mpv/mpv.conf".text = ''
          ${builtins.readFile ./configs/mpv.conf}

          # ── Perfil de hardware gerado em compilação para perfil: ${cfg.profile} ──────────
          ${hwPresetSection}

          # ── Ajuste de janela flutuante para Window Managers (tiling) ───────────
          ${optionalString (isWM && cfg.floating) ''
            # Como ${
              if desktop != null then desktop else "WM"
            } é uma Window Manager, assegura dimensões e centralização de janela flutuante
            autofit-larger=85%x85%
            geometry=50%:50%
          ''}

          # ── Ativação do perfil de hardware por omissão para todos os ficheiros ──
          [default]
          profile=hw-preset
        '';

        # Atalhos de teclado — todos em input.conf (substitui bindings.conf)
        "mpv/input.conf".source = ./configs/input.conf;

        # Scripts customizados
        "mpv/scripts/gvfs-smb.lua".source = ./scripts/gvfs-smb.lua;

        # Scripts comunitários (implantados no ~/.config/mpv/scripts quando o MPV nativo do sistema é utilizado)
        "mpv/scripts/modernz.lua" = mkIf (!shouldInstall) {
          source = "${pkgs.mpvScripts.modernz}/share/mpv/scripts/modernz.lua";
        };
        "mpv/scripts/memo.lua" = mkIf (!shouldInstall) {
          source = "${pkgs.mpvScripts.memo}/share/mpv/scripts/memo.lua";
        };
        "mpv/scripts/evafast.lua" = mkIf (!shouldInstall) {
          source = "${pkgs.mpvScripts.evafast}/share/mpv/scripts/evafast.lua";
        };
        "mpv/scripts/thumbfast.lua" = mkIf (!shouldInstall) {
          source = "${pkgs.mpvScripts.thumbfast}/share/mpv/scripts/thumbfast.lua";
        };
        "mpv/scripts/sponsorblock_minimal.lua" = mkIf (!shouldInstall) {
          source = "${pkgs.mpvScripts.sponsorblock-minimal}/share/mpv/scripts/sponsorblock_minimal.lua";
        };

        # Script opts
        "mpv/script-opts/osc.conf".source = ./configs/opts/osc.conf;
        # "mpv/script-opts/uosc.conf".source = ./configs/opts/uosc.conf;
        "mpv/script-opts/modernz.conf".source = ./configs/opts/modernz.conf;
        "mpv/script-opts/thumbfast.conf".source = ./configs/opts/thumbfast.conf;
        "mpv/script-opts/evafast.conf".source = ./configs/opts/evafast.conf;
        "mpv/script-opts/memo.conf".source = ./configs/opts/memo.conf;

        # Fontes customizadas para scripts e OSD (ícones oficiais do ModernZ)
        "mpv/fonts/modernz-icons.ttf".source = "${pkgs.mpvScripts.modernz.src}/modernz-icons.ttf";
      };

      mimeApps.defaultApplications = lib.genAttrs mediaMimeTypes (_: "mpv.desktop");

      desktopEntries = mkIf (cfg.defaultNvidia || (!shouldInstall && !isNixOS) || cfg.hybridGraphics) {
        mpv = {
          name = "mpv Media Player";
          genericName = "Multimedia player";
          comment = "Play movies and songs" + optionalString cfg.defaultNvidia " (NVIDIA dGPU)";
          icon = "mpv";
          exec = if cfg.defaultNvidia then nvidiaExec else intelExec;
          terminal = false;
          categories = [
            "AudioVideo"
            "Audio"
            "Video"
            "Player"
            "TV"
          ];
          mimeType = mediaMimeTypes;
          actions =
            if cfg.defaultNvidia then
              {
                open-intel = {
                  name = "Open with Intel iGPU";
                  exec = intelExec;
                };
              }
            else
              (optionalAttrs cfg.hybridGraphics {
                open-nvidia = {
                  name = "Open with NVIDIA dGPU";
                  exec = nvidiaExec;
                };
              });
        };
      };

      # Sobrescreve a prioridade de .ts para que o shared-mime-info o identifique como vídeo MPEG-2 TS
      # em vez de catálogo de mensagens do Qt Linguist (weight 60 > weight 50 padrão)
      dataFile."mime/packages/override-ts.xml".text = ''
        <?xml version="1.0" encoding="utf-8"?>
        <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
          <mime-type type="video/mp2t">
            <comment>MPEG-2 transport stream</comment>
            <glob pattern="*.ts" weight="60"/>
          </mime-type>
        </mime-info>
      '';
    };

    # ─────────────────────────────────────────────────────────────────────────
    # Regras de janela para Window Managers (quando não for Desktop completo)
    # Garante que o MPV abra em modo flutuante apenas quando cfg.floating = true.
    # ─────────────────────────────────────────────────────────────────────────
    xsession.windowManager.bspwm.rules = mkIf (isWM && desktop == "bspwm" && cfg.floating) {
      "mpv" = {
        state = "floating";
        center = true;
      };
      "Mpv" = {
        state = "floating";
        center = true;
      };
    };

    wayland.windowManager.hyprland.settings.windowrule =
      mkIf (isWM && desktop == "hyprland" && cfg.floating)
        [
          "match:class ^(mpv)$, float 1"
          "match:class ^(mpv)$, center 1"
        ];

    wayland.windowManager.sway.config.floating.criteria =
      mkIf (isWM && desktop == "sway" && cfg.floating)
        [
          { app_id = "mpv"; }
          { class = "mpv"; }
        ];

    xsession.windowManager.i3.config.floating.criteria =
      mkIf (isWM && desktop == "i3" && cfg.floating)
        [
          { class = "mpv"; }
          { instance = "mpv"; }
        ];

    home = {
      packages = [
        pkgs.font-dubai
      ]
      ++ lib.optionals (!shouldInstall && !isNixOS) [
        (pkgs.writeShellScriptBin "mpv" ''
          : ''${__GLX_VENDOR_LIBRARY_NAME:=mesa}
          export __GLX_VENDOR_LIBRARY_NAME
          exec /usr/bin/mpv "$@"
        '')
      ];

      # Atualiza o banco de dados MIME do usuário caso update-mime-database esteja disponível
      activation.updateMimeDatabase = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if command -v update-mime-database >/dev/null 2>&1; then
          $DRY_RUN_CMD update-mime-database "$HOME/.local/share/mime" >/dev/null 2>&1 || true
        fi
      '';
    };

    systemd.user.tmpfiles.rules = mkIf pkgs.stdenv.isLinux [
      "d ${config.home.homeDirectory}/.logs 0755 - - - -"
      "d ${config.home.homeDirectory}/.logs/mpv 0755 - - - -"
      "d ${config.home.homeDirectory}/.cache/mpv/script-opts 0755 - - - -"
    ];
  };
}
