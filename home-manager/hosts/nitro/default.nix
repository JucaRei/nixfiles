{
  pkgs,
  config,
  lib,
  ...
}:
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
    desktop = {
      monitors = [
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

      modifierKey = "Alt";
    };

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
      file-manager = {
        thunar.enable = true;
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
      packages =
        with pkgs;
        [
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
          scrcpy
          solaar
        ]
        ++ lib.optionals config.system.programs.multimedia.mpv.enable [
          (pkgs.writeShellScriptBin "mpv-nvidia" ''
            # Executa o MPV com PRIME Offload na NVIDIA dGPU (NVDEC/CUDA)
            # Detecta automaticamente se utiliza o binário do Nix ou o nativo da distribuição
            if [ -x "$HOME/.nix-profile/bin/mpv" ]; then
              mpv_bin="$HOME/.nix-profile/bin/mpv"
              # Injeta apenas os diretórios dedicados do driver proprietário NVIDIA (sem libc do Debian)
              # Isso expõe libcuda.so.1 e libnvcuvid.so.1 para aceleração por hardware (NVDEC/CUDA)
              # sem conflitar com a glibc do Nix Store.
              for nv_dir in /usr/lib/x86_64-linux-gnu/nvidia/current /usr/lib64/nvidia; do
                if [ -d "$nv_dir" ]; then
                  export LD_LIBRARY_PATH="$nv_dir''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
                fi
              done
            elif [ -x /usr/bin/mpv ]; then
              # Modo nativo: limpa variáveis do Nix que causam conflito de ABI com bibliotecas do Debian
              unset LD_LIBRARY_PATH
              unset LIBVA_DRIVERS_PATH
              unset LIBVA_DRIVER_NAME
              unset LIBGL_DRIVERS_PATH
              unset GBM_BACKENDS_PATH
              unset __EGL_VENDOR_LIBRARY_FILENAMES
              mpv_bin="/usr/bin/mpv"
            else
              echo "mpv-nvidia: nenhum binário do mpv (Nix ou /usr/bin/mpv) encontrado!" >&2
              exit 1
            fi

            exec env __NV_PRIME_RENDER_OFFLOAD=1 \
                     __VK_LAYER_NV_optimus=NVIDIA_only \
                     "$mpv_bin" --profile=nvidia "$@"
          '')
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

    # Solaar para gerenciamento do teclado Logitech MX Keys e dispositivos Unifying/Bolt
    systemd.user.services.solaar = {
      Unit = {
        Description = "Solaar (Logitech Device Manager)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.solaar}/bin/solaar --window=hide";
        Restart = "on-failure";
        RestartSec = 3;
        PassEnvironment = [
          "DISPLAY"
          "XAUTHORITY"
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
