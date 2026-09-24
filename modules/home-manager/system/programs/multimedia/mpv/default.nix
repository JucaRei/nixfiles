{
  config,
  lib,
  pkgs,
  hostname,
  desktop ? null,
  nixGLWrapper ? (x: x),
  isNvidia ? false,
  osConfig ? null,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption optionalString;
  cfg = config.system.programs.multimedia.mpv;
  isNixOS = osConfig != null;
  shouldInstall = cfg.installPackage && !cfg.useSystemPackage && !cfg.useSystemPackages;

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

  # ─────────────────────────────────────────────────────────────────────────────
  # Perfil de hardware [hw-preset] em formato mpv.conf nativo.
  # Gerado em tempo de compilação Nix por host — sem runtime env vars.
  # Activado pela linha `profile=hw-preset` no fim de mpv.conf.
  # ─────────────────────────────────────────────────────────────────────────────
  hwPresetSection =
    (if !shouldInstall then
      ''
        [hw-preset]
        profile-desc=Distro Nativa: Perfil Universal Seguro (auto hwdec, vo=gpu,x11)
        vo=gpu,x11
        gpu-api=auto
        hwdec=vaapi-copy,vaapi,no
        video-sync=audio
        ${optionalString (hostname == "nixtro" || hostname == "nitro") ''
          vaapi-device=/dev/dri/by-path/pci-0000:00:02.0-render
        ''}
      ''

    # ── Acer Nitro 5 AN52 — Intel (iGPU) + NVIDIA GTX/RTX (dGPU) ─────────────
    # Driver proprietário NVIDIA. Vulkan + nvdec-copy para decodificação acelerada.
    # nvdec-copy é mais compatível que nvdec pois não usa zero-copy com VA-API.
    else if hostname == "nixtro" || hostname == "nitro" then
      ''
        [hw-preset]
        profile-desc=Nitro 5: Intel UHD 630 via nixGLIntel (vaapi, opengl)
        vo=gpu,x11
        gpu-api=opengl
        hwdec=vaapi
        gpu-shader-cache-dir=~/.cache/mpv/shaders
        video-sync=display-resample
      ''

    # ── MacBook Pro 4,1 (Early 2008) — NVIDIA 8600M GT / Nouveau (NV50) ────────
    # Nouveau NV50 não suporta Vulkan. OpenGL + VAAPI via Mesa.
    # Escaladores bilinear reduzem carga no Core 2 Duo Penryn (2 núcleos, ~2.4GHz).
    else if hostname == "rocinante" then
      if isNvidia then
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
      else
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

    # ── MacBook Air 4,1 — Intel HD 3000, 2 GB RAM ──────────────────────────────
    # Memória limitada: cache reduzido, escaladores leves, sem pré-processamento.
    # video-sync=audio evita o overhead de display-resample em hardware fraco.
    else if hostname == "anubis" then
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

    # ── Hyper-V Virtual Machine — sem aceleração 3D por hardware ───────────────
    # Evita tentativas de Vulkan e DRM KMS que falham no adaptador virtual do Hyper-V.
    else if hostname == "rocinante-hyperv" then
      ''
        [hw-preset]
        profile-desc=Hyper-V: Software rendering (x11, sem hwdec)
        vo=x11
        hwdec=no
        video-sync=audio
      ''

    # ── Fallback genérico para outros hosts / VMs ──────────────────────────────
    else
      ''
        [hw-preset]
        profile-desc=Generic: auto hwdec (auto-safe, opengl)
        vo=gpu
        gpu-api=auto
        hwdec=auto-safe
      '')
    + (optionalString (hostname == "nixtro" || hostname == "nitro") ''

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
    # Toda a configuração é gerida como ficheiros — sem attrsOf em Nix.
    # Vantagem: editável directamente, sem recompilar o flake para ajustes.
    # ─────────────────────────────────────────────────────────────────────────
    xdg.configFile = {

      # mpv.conf base (configs/mpv.conf) + perfil de hardware injetado via Nix
      # O perfil [hw-preset] define as configurações de hardware e é activado no [default].
      "mpv/mpv.conf".text = ''
        ${builtins.readFile ./configs/mpv.conf}

        # ── Perfil de hardware gerado em compilação para: ${hostname} ──────────
        ${hwPresetSection}

        # ── Ajuste de janela flutuante para Window Managers (tiling) ───────────
        ${optionalString isWM ''
          # Como ${if desktop != null then desktop else "WM"} é uma Window Manager, assegura dimensões e centralização de janela flutuante
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

    # ─────────────────────────────────────────────────────────────────────────
    # Regras de janela para Window Managers (quando não for Desktop completo)
    # Garante que o MPV abra sempre em modo flutuante (floating) e centralizado.
    # ─────────────────────────────────────────────────────────────────────────
    xsession.windowManager.bspwm.rules = mkIf (isWM && desktop == "bspwm") {
      "mpv" = {
        state = "floating";
        center = true;
      };
      "Mpv" = {
        state = "floating";
        center = true;
      };
    };

    wayland.windowManager.hyprland.settings.windowrule = mkIf (isWM && desktop == "hyprland") [
      "match:class ^(mpv)$, float 1"
      "match:class ^(mpv)$, center 1"
    ];

    wayland.windowManager.sway.config.floating.criteria = mkIf (isWM && desktop == "sway") [
      { app_id = "mpv"; }
      { class = "mpv"; }
    ];

    xsession.windowManager.i3.config.floating.criteria = mkIf (isWM && desktop == "i3") [
      { class = "mpv"; }
      { instance = "mpv"; }
    ];

    xdg.mimeApps.defaultApplications = {
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/mkv" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
      "audio/mp3" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
      "audio/ogg" = "mpv.desktop";
      "audio/wav" = "mpv.desktop";
      "audio/aac" = "mpv.desktop";
    };

    home.packages = [
      pkgs.font-dubai
    ] ++ lib.optionals (!shouldInstall && !isNixOS) [
      (pkgs.writeShellScriptBin "mpv" ''
        : ''${__GLX_VENDOR_LIBRARY_NAME:=mesa}
        export __GLX_VENDOR_LIBRARY_NAME
        exec /usr/bin/mpv "$@"
      '')
    ];

    xdg.desktopEntries = mkIf (!shouldInstall && !isNixOS) {
      mpv = {
        name = "mpv Media Player";
        genericName = "Multimedia player";
        comment = "Play movies and songs";
        icon = "mpv";
        exec = "env __GLX_VENDOR_LIBRARY_NAME=mesa mpv --player-operation-mode=pseudo-gui -- %U";
        terminal = false;
        categories = [
          "AudioVideo"
          "Audio"
          "Video"
          "Player"
          "TV"
        ];
        mimeType = [
          "application/ogg"
          "application/x-ogg"
          "application/mkv"
          "application/x-matroska"
          "audio/mp4"
          "audio/mpeg"
          "audio/ogg"
          "video/mp4"
          "video/mkv"
          "video/x-matroska"
          "video/webm"
        ];
      };
    };

    systemd.user.tmpfiles.rules = mkIf pkgs.stdenv.isLinux [
      "d ${config.home.homeDirectory}/.logs 0755 - - - -"
      "d ${config.home.homeDirectory}/.logs/mpv 0755 - - - -"
      "d ${config.home.homeDirectory}/.cache/mpv/script-opts 0755 - - - -"
    ];
  };
}
