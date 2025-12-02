{ config, lib, pkgs, username, hostname, nixGLWrapper ? (x: x), ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.system.programs.multimedia.mpv;

  # anime4K_LowEnd = ''
  #   # Optimized shaders for lower-end GPU:
  #   CTRL+1 no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_M.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A (Fast)"
  #   CTRL+2 no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B (Fast)"
  #   CTRL+3 no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C (Fast)"
  #   CTRL+4 no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_M.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_S.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A+A (Fast)"
  #   CTRL+5 no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_Soft_S.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B+B (Fast)"
  #   CTRL+6 no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_S.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C+A (Fast)"

  #   CTRL+0 no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"
  # '';

  # anime4K_HighEnd = ''
  #   # Optimized shaders for higher-end GPU:
  #   CTRL+1 no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_VL.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A (HQ)"
  #   CTRL+2 no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B (HQ)"
  #   CTRL+3 no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C (HQ)"
  #   CTRL+4 no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_VL.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A+A (HQ)"
  #   CTRL+5 no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B+B (HQ)"
  #   CTRL+6 no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_M.glsl:${pkgs.anime4k} /Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C+A (HQ)"

  #   CTRL+0 no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"
  # '';
in
{
  options = {
    enable = mkEnableOption "Enable's mpv with custom settings as default";
  };

  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      package = nixGLWrapper pkgs.mpv-unwrapped.wrapper {
        mpv = pkgs.mpv-unwrapped.override {
          vapoursynthSupport = true;
        };
        youtubeSupport = true;
      };
      bindings = (builtins.readFile ./configs/bindings.conf);
      extraInput = ''
        esc         quit                                              #! Quit
        Ctrl+l      cycle-values sub-lang pt_BR en eng de deu ger     #! Cycle subtitle order
        Ctrl+n      af-toggle=@dynaudnorm:lavfi=[dynaudnorm=g=5:f=250:r=0.9:p=0.5]
        Ctrl+m      af-toggle=@loudnorm:lavfi=[loudnorm=I=-16:TP=-3:LRA=4]
        Ctrl+t      apply-profile hdr-sdr

        Alt+h       add sub-delay +1
        Alt+1       add sub-delay -1

        Alt+h       add sub-scale +0.1
        Alt+j       add sub-scale -0.1

        B           cycle-values background "#000000" "#ffffff"
      '';
      config = (builtins.readFile ./configs/mpv.conf);
      defaultProfiles = [
        "gpu-context = auto"
        "ordered-chapters = true"
      ];
      profiles = {
        "mbp-air" = {
          profile-cond = "os.getenv('HOSTNAME') == 'anubis'";
          brightness = 70;
          vo = "auto-safe";
        };

        "hdr-sdr" = {
          profile-desc = "Tone-map HDR to SDR";
          tone-mapping = "bt.2446a";
          tone-mapping-mode = "luma";
          target-colorscpace-hint = "yes";
        };

        "protocol.http" = {
          cache = true;
          ytdl-format = "(webm,mkv,mp4)[height<=?720]";
          ytdl-raw-options = "ignore-config=,sub-lang=en,write-auto-sub=";
          hls-bitrate = "max"; # use max quality for HLS streams
          force-window = "immediate";
        };
        "protocol.https" = {
          profile = "protocol.http";
          ytdl-format = "(webm,mkv,mp4)[height<=?720]";
          ytdl-raw-options = "ignore-config=,sub-lang=en,write-auto-sub=";
          cache = true;
        };

        "extension.gif" = {
          cache = false;
          loop-file = true;
        };

        "extension.png" = {
          profile = "extension.gif";
          video-aspect-override = 0;
        };

        "extension.jpeg".profile = "extension.png";
        "extension.jpg".profile = "extension.png";
      };
      scriptOpts = {
        osc = {
          seekbarstyle = "knob"; # "diamond";
          seekbarkeyframes = false;
          seekrangestyle = "slider";
          vidscale = false;
          deadzonesize = 0.75;
          inmousemove = 4;
          valign = 0.9;
          timems = true;
          scalewindowed = 0.8;
          hidetimeout = 300;
          layout = "slimbox";
        };
        uosc = builtins.readFile ./configs/opts/uosc.conf;
        thumbfast = builtins.readFile ./configs/opts/thumbfast.conf;
        evafast = builtins.readFile ./configs/opts/evafast.conf;
        memo = builtins.readFile ./configs/opts/memo.conf;
      };
      scripts = with pkgs.mpvScripts; [
        uosc
        memo
        evafast
        thumbfast
        mpv-cheatsheet
        sponsorblock-minimal
      ];
    };

    home = {
      packages = with pkgs; [
        font-dubai
      ];
    };

    systemd.user.tmpfiles.rules = mkIf pkgs.stdenv.isLinux [
      "d ${config.home.homeDirectory}/.logs 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/.logs/mpv 0755 ${username} users - -"
    ];
  };
}

