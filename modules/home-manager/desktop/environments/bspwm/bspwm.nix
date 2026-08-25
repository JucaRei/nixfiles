{ config, lib, pkgs, useNixGL ? false, desktop ? null, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool listOf str;
  cfg = config.desktop.bspwm;

  nixGL = import ../../../../../lib/nixGL.nix { inherit pkgs; };
  nixGLWrapper = if useNixGL then nixGL.wrapper else (x: x);
in
{
  options.desktop.bspwm = {
    enable = mkOption {
      type = bool;
      default = (desktop == "bspwm");
      description = "Enable bspwm window manager";
    };

    extraConfig = mkOption {
      type = str;
      default = "";
      description = "Additional bspwmrc configuration to append";
    };

    rules = mkOption {
      type = listOf str;
      default = [ ];
      description = "bspwm rules for specific applications";
    };
  };

  config = mkIf cfg.enable {
    xsession = {
      enable = true;
      profilePath = ".xprofile";
      windowManager = {
        bspwm = {
          enable = true;
          package = nixGLWrapper pkgs.bspwm;
          monitors = { };
          settings = {
            split_ratio = 0.52;
            border_width = 2;
            window_gap = 6;
            top_padding = 34; # Altura da Polybar (30px + espaçamento)
            bottom_padding = 4;
            left_padding = 4;
            right_padding = 4;
            normal_border_color = "#313244";
            active_border_color = "#45475a";
            focused_border_color = "#89b4fa";
            presel_feedback_color = "#f38ba8";
          };
          rules = {
            "Pavucontrol" = { state = "floating"; };
            "GParted" = { state = "floating"; };
            "Galculator" = { state = "floating"; };
            "Flameshot" = { state = "floating"; };
            "Lxappearance" = { state = "floating"; };
            "Xfce4-taskmanager" = { state = "floating"; };
            "File-roller" = { state = "floating"; };
            "Nitrogen" = { state = "floating"; };
            "Catfish" = { state = "floating"; };
          };
          extraConfig = ''
            # Configurar workspaces 1 a 10 (onde 0 = 10) em todos os monitores conectados
            for m in $(bspc query -M); do
              bspc monitor "$m" -d 1 2 3 4 5 6 7 8 9 10
            done

            # Iniciar daemon de atalhos de teclado (SXHKD)
            pkill -x sxhkd || true
            ${pkgs.sxhkd}/bin/sxhkd &

            # Cursor padrão
            xsetroot -cursor_name left_ptr &

            # Importar variáveis de ambiente para serviços do usuário
            systemctl --user import-environment DISPLAY XAUTHORITY

            # Agente de autenticação Polkit
            ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &

            # Wallpaper / Fundo
            xsetroot -solid '#1e1e2e' &

            # Applet de Rede (após importar DISPLAY)
            ${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable &

            # Mouse bindings para mover e redimensionar janelas flutuantes
            bspc config pointer_modifier mod4
            bspc config pointer_action1 move
            bspc config pointer_action2 resize_side
            bspc config pointer_action3 resize_corner

            # Foco segue o ponteiro
            bspc config focus_follows_pointer true

            # Regras customizadas adicionais
            ${lib.concatStringsSep "\n" cfg.rules}

            ${cfg.extraConfig}
          '';
        };
      };
    };

    home = {
      sessionVariables = {
        "_JAVA_AWT_WM_NONREPARENTING" = "1";
        GLFW_IM_MODULE = "ibus";
        TERM = "alacritty"; # Compatível com o Alacritty
        QT_STYLE_OVERRIDE = lib.mkDefault "kvantum";
        LOG_ICONS = "true";
      };

      shellAliases = {
        is_picom_on = "pgrep -x 'picom' > /dev/null && echo 'on' || echo 'off'";
      };
    };
  };
}
