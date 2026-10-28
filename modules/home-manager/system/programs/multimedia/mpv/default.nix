{
  config,
  lib,
  pkgs,
  desktop ? null,
  nixGLWrapper ? (x: x),
  isNvidia ? false,
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
  mediaMimeTypes = [
    # Vídeo - MPEG Transport Stream (.ts, .m2t)
    # Nota: No freedesktop/shared-mime-info, a extensão .ts é historicamente associada
    # a text/vnd.trolltech.linguist ("Message catalog" do Qt Linguist).
    # Mapeamos também ao MPV para que esses arquivos de vídeo abram diretamente
    # no player pelo gerenciador de arquivos sem disparar erro de permissão no mimeapps.list.
    "video/mp2t"
    "video/ts"
    "video/vnd.dlna.mpeg-tts"
    "text/vnd.trolltech.linguist"
    "application/x-linguist"

    # Vídeo - Matroska / MKV (.mkv)
    "video/x-matroska"
    "video/mkv"
    "application/x-matroska"
    "application/mkv"

    # Vídeo - MP4 / M4V (.mp4, .m4v)
    "video/mp4"
    "video/mp4v-es"
    "video/x-m4v"
    "application/x-extension-mp4"

    # Vídeo - WebM (.webm)
    "video/webm"

    # Vídeo - AVI (.avi)
    "video/x-msvideo"
    "video/avi"
    "video/msvideo"
    "video/vnd.avi"

    # Vídeo - QuickTime (.mov, .qt)
    "video/quicktime"

    # Vídeo - MPEG (.mpg, .mpeg, .m2v)
    "video/mpeg"
    "video/mpeg2"
    "video/x-mpeg"
    "video/x-mpeg2"
    "video/x-mpeg3"
    "video/mpv"
    "video/mpeg-system"

    # Vídeo - OGG / Theora / OGM (.ogv, .ogg, .ogm)
    "video/ogg"
    "video/x-ogm"
    "video/x-ogm+ogg"
    "video/x-theora"
    "video/x-theora+ogg"
    "application/ogg"
    "application/x-ogg"

    # Vídeo - Flash Video (.flv, .f4v)
    "video/x-flv"
    "video/flv"

    # Vídeo - Windows Media Video (.wmv, .asf)
    "video/x-ms-wmv"
    "video/x-ms-asf"
    "video/x-ms-asx"
    "video/x-ms-wvx"

    # Vídeo - 3GP / 3GPP (.3gp, .3g2)
    "video/3gpp"
    "video/3gpp2"

    # Vídeo - DivX (.divx)
    "video/divx"
    "video/vnd.divx"

    # Vídeo - DV & RealMedia (.dv, .rm, .rmvb)
    "video/dv"
    "video/x-dv"
    "video/vnd.rn-realmedia"

    # Vídeo - Streams e Playlists HLS / MPEG-URL (.m3u, .m3u8)
    "video/vnd.mpegurl"
    "application/vnd.apple.mpegurl"

    # Áudio - MP3 / MPEG Audio (.mp3)
    "audio/mp3"
    "audio/x-mp3"
    "audio/mpeg"
    "audio/x-mpeg"
    "audio/mpg"
    "audio/x-mpg"
    "audio/mpeg3"
    "audio/x-mpeg3"
    "audio/mp1"
    "audio/x-mp1"
    "audio/mp2"
    "audio/x-mp2"

    # Áudio - FLAC (.flac)
    "audio/flac"
    "audio/x-flac"

    # Áudio - OGG / Vorbis / Opus (.ogg, .oga, .opus)
    "audio/ogg"
    "audio/x-ogg"
    "audio/vorbis"
    "audio/x-vorbis"
    "audio/x-vorbis+ogg"
    "audio/opus"
    "audio/x-opus"

    # Áudio - WAV (.wav)
    "audio/wav"
    "audio/x-wav"
    "audio/wave"
    "audio/x-pn-wav"

    # Áudio - AAC / M4A / MP4 Audio (.aac, .m4a, .mp4)
    "audio/aac"
    "audio/x-aac"
    "audio/m4a"
    "audio/x-m4a"
    "audio/mp4"
    "application/x-extension-m4a"

    # Áudio - Matroska Audio (.mka) & WebM Audio (.weba)
    "audio/x-matroska"
    "audio/webm"

    # Áudio - Windows Media Audio (.wma)
    "audio/x-ms-wma"
    "audio/x-ms-wax"
    "audio/x-ms-asf"

    # Áudio - AIFF (.aiff, .aif)
    "audio/aiff"
    "audio/x-aiff"

    # Áudio - Formatos lossless adicionais (APE, WavPack, Musepack)
    "audio/ape"
    "audio/x-ape"
    "audio/wavpack"
    "audio/x-wavpack"
    "audio/musepack"
    "audio/x-musepack"

    # Áudio - RealAudio (.ra, .ram)
    "audio/vnd.rn-realaudio"

    # Áudio - Playlists (.m3u, .m3u8, .pls)
    "audio/mpegurl"
    "audio/x-mpegurl"
    "audio/x-scpls"
  ];

  # ─────────────────────────────────────────────────────────────────────────────
  # Perfil de hardware [hw-preset] em formato mpv.conf nativo.
  # Gerado em tempo de compilação Nix por host — sem runtime env vars.
  # Activado pela linha `profile=hw-preset` no fim de mpv.conf.
  # ─────────────────────────────────────────────────────────────────────────────
  hwPresetSection =
    (
      if !shouldInstall then
        ''
          [hw-preset]
          profile-desc=Distro Nativa: Perfil Universal Seguro (auto hwdec, vo=gpu,x11)
          vo=gpu,x11
          gpu-api=auto
          hwdec=vaapi-copy,vaapi,no
          video-sync=audio
          ${optionalString (cfg.vaapiDevice != null) ''
            vaapi-device=${cfg.vaapiDevice}
          ''}
        ''
      else if cfg.profile == "nitro" then
        ''
          [hw-preset]
          profile-desc=Nitro 5: Intel UHD 630 via nixGLIntel (vaapi, opengl)
          vo=gpu,x11
          gpu-api=opengl
          hwdec=vaapi
          gpu-shader-cache-dir=~/.cache/mpv/shaders
          video-sync=display-resample
        ''
      else if cfg.profile == "legacy-nvidia" then
        ''
          [hw-preset]
          profile-desc=Rocinante: NVIDIA 340 Legacy (Proprietário)
          vo=gpu
          gpu-api=opengl
          hwdec=no
          profile=fast
          scale=bilinear
          cscale=bilinear
          dscale=bilinear
        ''
      else if cfg.profile == "legacy-nouveau" then
        ''
          [hw-preset]
          profile-desc=Rocinante: Nouveau (Open Source)
          vo=gpu
          gpu-api=opengl
          hwdec=vaapi
          scale=bilinear
          cscale=bilinear
          dscale=bilinear
        ''
      else if cfg.profile == "low-ram" then
        ''
          [hw-preset]
          profile-desc=MacBook Air: Intel HD 3000 (vaapi, opengl, 2GB RAM)
          vo=gpu
          gpu-api=opengl
          hwdec=vaapi
          scale=bilinear
          cscale=bilinear
          dscale=bilinear
          correct-downscaling=no
          sigmoid-upscaling=no
          cache-secs=5
          video-sync=audio
        ''
      else if cfg.profile == "software" then
        ''
          [hw-preset]
          profile-desc=Hyper-V: Software rendering (x11, sem hwdec)
          vo=x11
          hwdec=no
          video-sync=audio
        ''
      else
        ''
          [hw-preset]
          profile-desc=Generic: auto hwdec (auto-safe, opengl)
          vo=gpu
          gpu-api=auto
          hwdec=auto-safe
        ''
    )
    + (optionalString cfg.hybridGraphics ''

      [nvidia]
      profile-desc=Nitro 5: NVIDIA dGPU via PRIME (nvdec/cuda/auto)
      vo=gpu
      gpu-api=auto
      hwdec=nvdec-copy,cuda-copy,auto-safe
      gpu-shader-cache-dir=~/.cache/mpv/shaders-nvidia
      video-sync=display-resample
    '');
in
{
  # Declara a opção no mesmo módulo que a implementa (padrão do repositório).
  # Segue o mesmo estilo de editors/vscode e editors/antigravity.
  options.system.programs.multimedia.mpv = {
    enable = mkEnableOption "mpv media player with custom profiles and scripts";

    installPackage = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Se deve instalar o executável do MPV compilado via Nix/Home Manager.
        Se definido como false, o Home Manager instalará apenas as configurações (mpv.conf, input.conf, scripts e opções de hardware)
        e utilizará o binário nativo do sistema operacional hospedeiro (ex: Debian /usr/bin/mpv).
      '';
    };

    useSystemPackage = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Atalho conveniente: quando true, equivale a installPackage = false.
        Permite carregar apenas as configurações preservando o MPV da distro nativa.
      '';
    };

    useSystemPackages = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Alias para useSystemPackage.";
    };

    defaultNvidia = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Se o MPV deve abrir por padrão utilizando a dGPU NVIDIA (PRIME offload / mpv-nvidia)
        no arquivo .desktop (sobrescrevendo mpv.desktop), incluindo uma ação secundária
        no menu de contexto para abrir com a iGPU Intel.
      '';
    };

    profile = lib.mkOption {
      type = lib.types.enum [
        "auto"
        "nitro"
        "legacy-nvidia"
        "legacy-nouveau"
        "low-ram"
        "software"
      ];
      default = if isNvidia then "legacy-nvidia" else "auto";
      description = ''
        Perfil de hardware para reprodução no MPV:
        - "auto": decodificação segura automática (vo=gpu, gpu-api=auto, hwdec=auto-safe)
        - "nitro": perfil otimizado para Intel UHD 630 + NVIDIA dGPU
        - "legacy-nvidia": perfil para GPUs legadas com driver proprietário antigo (ex: NVIDIA 340)
        - "legacy-nouveau": perfil para GPUs legadas com driver Nouveau / Mesa
        - "low-ram": perfil econômico para máquinas com pouca RAM (ex: MacBook Air 2GB)
        - "software": perfil para renderização puramente por software em VMs sem aceleração 3D
      '';
    };

    vaapiDevice = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Dispositivo de renderização VA-API opcional (ex: /dev/dri/by-path/pci-0000:00:02.0-render).";
    };

    hybridGraphics = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Habilitar suporte e ações de dGPU NVIDIA / PRIME no desktop entry e perfil [nvidia].";
    };

    floating = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Se o MPV deve abrir em modo flutuante (floating) em Window Managers (BSPWM, Hyprland, Sway, i3).
        Defina como false para abrir diretamente em modo tiled na grade.
      '';
    };
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
