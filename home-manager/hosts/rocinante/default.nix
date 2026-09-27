{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  # Verificação se o host está configurado com driver proprietário NVIDIA ou open-source Nouveau
  gpuDriver = osConfig.hardware.graphics.cards.gpu or null;
  isNvidiaLegacy = (gpuDriver == "nvidia-legacy");

  # Utilitário de diagnóstico em tempo real para verificar driver de vídeo ativo no MacBook Pro
  gpuDriverCheck = pkgs.writeShellScriptBin "rocinante-gpu-check" ''
    echo "========================================================"
    echo "    Rocinante (MacBook Pro 4,1) - GPU Driver Status"
    echo "========================================================"
    echo "Kernel Ativo: $(uname -r)"

    if [ -d /proc/driver/nvidia ]; then
      nvidia_ver=$(cat /proc/driver/nvidia/version 2>/dev/null | head -n1 || echo "NVIDIA 340.108 Legacy")
      echo "Driver em Uso:   PROPRIETÁRIO NVIDIA LEGACY"
      echo "Versão Driver:   $nvidia_ver"
      echo "Aceleração 3D:   GLX Monolítico (/run/opengl-driver/lib/libGL.so.1)"
      echo "Perfil Gráfico:  specialisation.nvidia (GRUB)"
      echo "Barra Quickshell: OpenGL via GLX nativo"
    elif [ -d /sys/module/nouveau ]; then
      echo "Driver em Uso:   OPEN-SOURCE NOUVEAU"
      echo "Aceleração 3D:   Mesa Gallium DRI (nouveau_dri.so)"
      echo "Perfil Gráfico:  Padrão (Kernel Zen)"
      echo "Barra Quickshell: OpenGL nativo via Mesa"
    else
      echo "Driver em Uso:   Genérico / Desconhecido"
    fi

    echo "--------------------------------------------------------"
    if command -v glxinfo >/dev/null 2>&1; then
      echo "OpenGL Vendor:   $(glxinfo 2>/dev/null | grep 'OpenGL vendor string' | cut -d: -f2 | xargs)"
      echo "OpenGL Renderer: $(glxinfo 2>/dev/null | grep 'OpenGL renderer string' | cut -d: -f2 | xargs)"
      echo "OpenGL Version:  $(glxinfo 2>/dev/null | grep 'OpenGL version string' | cut -d: -f2 | xargs)"
    fi
    echo "========================================================"
  '';
in
{
  config = {
    system = {
      programs = {
        console = {
          bat.enable = true;
          eza.enable = true;
        };
        browsers = {
          firefox.enable = true;
        };
        editors = {
          vscode = {
            enable = true;
            enableConfigurableSettings = true;
          };
        };
        multimedia = {
          mpv.enable = true;
        };
        terminal = {
          enable = true;
          name = "alacritty";
        };
      };
    };

    programs.antigravity-cli.enable = true;

    # Adiciona a extensão Continue (Chat + Autocomplete com Gemini) especificamente na Rocinante
    programs.vscode.profiles.default.extensions =
      lib.mkIf config.system.programs.editors.vscode.enable
        (
          pkgs.nix4vscode.forVscode [
            "Continue.continue"
          ]
        );

    desktop = {
      modifierKey = "Super"; # Tecla Command (⌘) do Mac como Super (Mod4) principal no DWM
    };

    # Configuração declarativa do DWM no MacBook Pro 4,1 (Intel Core 2 Duo / GeForce 8600M GT)
    desktop.dwm = {
      bar = "quickshell"; # Quickshell como barra padrão (ou "dwm-status" se preferir a barra nativa do DWM)
      quickshell = {
        # Se estiver com NVIDIA proprietário: forçar OpenGL (GLX), pois Vulkan e EGL não são suportados
        # Se estiver com Nouveau (open-source): Mesa suporta OpenGL/EGL nativamente
        qsgBackend = "opengl";
        glIntegration = if isNvidiaLegacy then "glx" else "auto";
      };
      keyboard.brightness = {
        enable = true;
        device = "smc::kbd_backlight"; # Dispositivo SMC de iluminação do teclado do MacBook Pro
        step = 5;
      };
      picom = {
        enable = true;
        backend = "xrender"; # CPU/GPU ultra-fria: sem shaders pesados na GPU legada
      };
    };

    # Compositor Picom ultra-leve para o BSPWM (mantido comentado como fallback)
    # desktop.bspwm.picom = {
    #   enable = true;
    #   backend = "xrender"; # CPU/GPU ultra-fria: sem shaders pesados na GPU legada
    #   animations.enable = false; # Desativa animações complexas para resposta instantânea
    #   blur.enable = false; # Sem blur (dual_kawase), zerando o uso de VRAM
    #   useDamage = true; # Repinta apenas as regiões modificadas da tela
    # };

    # Teclado Apple MacBook Pro: layout internacional com dead keys, Command = Super (Mod4) e Option = Alt (Mod1)
    home.keyboard = {
      layout = "us";
      variant = "intl";
      model = "apple";
    };

    home = {
      sessionVariables = {
        GPU_DRIVER_PROFILE = if isNvidiaLegacy then "nvidia-legacy" else "nouveau";
      };
      packages = with pkgs; [
        gpuDriverCheck
        direnv
        duf
        fzf
        ripgrep
        htop
        btop
      ];
    };
  };
}
