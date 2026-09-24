{ pkgs, config, ... }:
let
  fhd = {
    width = 1920;
    height = 1080;
    refresh = 60;
  };
  pt = "pt_BR.UTF-8";
  en = "en_US.UTF-8";
in
{
  config = {
    desktop.monitors = [
      (
        fhd
        // {
          name = "HDMI-1-0";
          x = 0;
          y = 0;
          primary = true;
        }
      )
      (
        fhd
        // {
          name = "eDP-1";
          x = 1920;
          y = 0;
          primary = false;
        }
      )
    ];

    system.programs = {
      console = {
        bat.enable = true;
        eza.enable = true;
      };
      browsers = {
        firefox.enable = true;
      };
      editors = {
        antigravity.enable = true;
      };
      terminal = {
        enable = true;
        name = "alacritty";
      };
      multimedia = {
        mpv = {
          enable = true;
          # useSystemPackages = true; # Usa o mpv nativo do Debian com o perfil universal seguro!
          installPackage = true;
        };
      };
      tools = {
        yt-dlp = {
          enable = true;
        };
      };
      shells = {
        default = "zsh";
      };
    };

    home = {
      packages = with pkgs; [
        git
        duf
        fzf
        ripgrep
        htop
        fastfetch
        intel-media-driver
        (pkgs.writeShellScriptBin "vainfo-intel" ''
          if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
            exec vainfo "$@"
          else
            intel_render="$(ls /dev/dri/by-path/*00:02.0-render 2>/dev/null || echo /dev/dri/renderD129)"
            exec vainfo --display drm --device "$intel_render" "$@"
          fi
        '')
        (pkgs.writeShellScriptBin "mpv-nvidia" ''
          # Executa o MPV com PRIME Offload na NVIDIA dGPU (NVDEC/CUDA)
          # Prefere o binário nativo do sistema pois tem acesso direto a
          # libcuda.so.1 e libnvcuvid.so.1 sem conflito com nixGLIntel
          if [ -x /usr/bin/mpv ]; then
            mpv_bin="/usr/bin/mpv"
          elif [ -x "$HOME/.nix-profile/bin/mpv" ]; then
            # Fallback: Nix mpv com injeção das libs CUDA/NVDEC do host
            export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
            mpv_bin="$HOME/.nix-profile/bin/mpv"
          else
            echo "mpv-nvidia: mpv não encontrado" >&2; exit 1
          fi
          exec env __NV_PRIME_RENDER_OFFLOAD=1 \
                   __VK_LAYER_NV_optimus=NVIDIA_only \
                   "$mpv_bin" --profile=nvidia "$@"
        '')
        scrcpy
      ];

      shellAliases = {
        vainfo = "vainfo-intel";
      };

      sessionPath = [
        "/usr/sbin"
        "/sbin"
      ];

      sessionVariables = {
        NIX_REMOTE = "daemon";
        LC_ALL = "";
        LIBVA_DRIVER_NAME = "iHD";
        LIBVA_DRIVERS_PATH = "/usr/lib/x86_64-linux-gnu/dri:${pkgs.intel-media-driver}/lib/dri";
      };

      language = {
        base = en;
        messages = en;
        ctype = pt;
        time = pt;
        numeric = pt;
        monetary = pt;
        paper = pt;
        name = pt;
        address = pt;
        telephone = pt;
        measurement = pt;
      };

      # Teclado com layouts US Internacional e ABNT2 (alternância via Polybar ou Alt+Shift)
      keyboard = {
        layout = "us,br";
        variant = "intl,abnt2";
        model = "pc105";
        options = [ "grp:alt_shift_toggle" ];
      };
    };

    programs.antigravity-cli.enable = true;

    # Exibição personalizada do teclado na Polybar para o host Nitro
    services.polybar.config."module/keyboard" = {
      layout-icon-0 = "us;INTL";
      layout-icon-1 = "br;ABNT2";
      label-layout = "%icon%";
    };
  };
}
