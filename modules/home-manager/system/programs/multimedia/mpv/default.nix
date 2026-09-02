{
  config,
  lib,
  pkgs,
  hostname,
  nixGLWrapper ? (x: x),
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.system.programs.multimedia.mpv;

  # ─────────────────────────────────────────────────────────────────────────────
  # Perfil de hardware [hw-preset] em formato mpv.conf nativo.
  # Gerado em tempo de compilação Nix por host — sem runtime env vars.
  # Activado pela linha `profile=hw-preset` no fim de mpv.conf.
  # ─────────────────────────────────────────────────────────────────────────────
  hwPresetSection =
    # ── Acer Nitro 5 AN52 — Intel (iGPU) + NVIDIA GTX/RTX (dGPU) ─────────────
    # Driver proprietário NVIDIA. Vulkan + nvdec-copy para decodificação acelerada.
    # nvdec-copy é mais compatível que nvdec pois não usa zero-copy com VA-API.
    if hostname == "nixtro" then
      ''
        [hw-preset]
        profile-desc=Nitro 5: NVIDIA dGPU (nvdec-copy, vulkan)
        vo=gpu
        gpu-api=vulkan
        hwdec=nvdec-copy
        gpu-shader-cache-dir=~/.cache/mpv/shaders
        icc-profile-auto=yes
        video-sync=display-resample
      ''

    # ── MacBook Pro 4,1 (Early 2008) — NVIDIA 8600M GT / Nouveau (NV50) ────────
    # Nouveau NV50 não suporta Vulkan. OpenGL + VAAPI via Mesa.
    # Escaladores bilinear reduzem carga no Core 2 Duo Penryn (2 núcleos, ~2.4GHz).
    else if hostname == "rocinante" then
      ''
        [hw-preset]
        profile-desc=Rocinante: Nouveau NV50 (vaapi, opengl, leve)
        vo=gpu
        gpu-api=opengl
        hwdec=vaapi
        scale=bilinear
        cscale=bilinear
        dscale=bilinear
        correct-downscaling=no
        sigmoid-upscaling=no
        video-sync=audio
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

    # ── Fallback genérico para outros hosts / VMs ──────────────────────────────
    else
      ''
        [hw-preset]
        profile-desc=Generic: auto hwdec (auto-safe, opengl)
        vo=gpu
        gpu-api=auto
        hwdec=auto-safe
      '';
in
{
  # Declara a opção no mesmo módulo que a implementa (padrão do repositório).
  # Segue o mesmo estilo de editors/vscode e editors/antigravity.
  options.system.programs.multimedia.mpv = {
    enable = mkEnableOption "mpv media player with custom profiles and scripts";
  };

  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;

      # nixGLWrapper envolve o binário para resolver libGL em ambientes não-NixOS
      package = nixGLWrapper pkgs.mpv-unwrapped.wrapper {
        mpv = pkgs.mpv-unwrapped.override {
          vapoursynthSupport = true;
        };
        youtubeSupport = true;
      };

      scripts = with pkgs.mpvScripts; [
        uosc # UI moderna (substitui o OSC builtin)
        memo # Histórico de ficheiros recentes
        evafast # Seeking rápido com preview
        thumbfast # Thumbnails na barra de progresso
        mpv-cheatsheet # Overlay de atalhos de teclado
        sponsorblock-minimal # Skip de segmentos SponsorBlock (YouTube)
      ];
    };

    # ─────────────────────────────────────────────────────────────────────────
    # Toda a configuração é gerida como ficheiros — sem attrsOf em Nix.
    # Vantagem: editável directamente, sem recompilar o flake para ajustes.
    # ─────────────────────────────────────────────────────────────────────────
    xdg.configFile = {

      # mpv.conf base (configs/mpv.conf) + perfil de hardware injetado via Nix
      # O perfil [hw-preset] varia por host; a linha profile= activa-o no arranque.
      "mpv/mpv.conf".text = ''
        ${builtins.readFile ./configs/mpv.conf}

        # ── Perfil de hardware gerado em compilação para: ${hostname} ──────────
        ${hwPresetSection}
        profile=hw-preset
      '';

      # Atalhos de teclado — todos em input.conf (substitui bindings.conf)
      "mpv/input.conf".source = ./configs/input.conf;

      # Script opts
      "mpv/script-opts/osc.conf".source = ./configs/opts/osc.conf;
      "mpv/script-opts/uosc.conf".source = ./configs/opts/uosc.conf;
      "mpv/script-opts/thumbfast.conf".source = ./configs/opts/thumbfast.conf;
      "mpv/script-opts/evafast.conf".source = ./configs/opts/evafast.conf;
      "mpv/script-opts/memo.conf".source = ./configs/opts/memo.conf;
    };

    home.packages = [ pkgs.font-dubai ];

    systemd.user.tmpfiles.rules = mkIf pkgs.stdenv.isLinux [
      "d ${config.home.homeDirectory}/.logs 0755 ${config.home.username} users - -"
      "d ${config.home.homeDirectory}/.logs/mpv 0755 ${config.home.username} users - -"
    ];
  };
}
