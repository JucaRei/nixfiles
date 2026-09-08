{
  config,
  lib,
  pkgs,
  desktop ? null,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool str listOf;
  cfg = config.desktop.hyprland;

  screenshotFull = pkgs.writeShellScript "hypr-screenshot-full" ''
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
    ${pkgs.grim}/bin/grim "$file"
    ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
    ${pkgs.libnotify}/bin/notify-send -i "$file" "Captura de Tela" "Captura completa salva em Pictures/Screenshots e copiada."
  '';

  screenshotArea = pkgs.writeShellScript "hypr-screenshot-area" ''
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
    geometry="$(${pkgs.slurp}/bin/slurp)"
    [ -z "$geometry" ] && exit 0
    ${pkgs.grim}/bin/grim -g "$geometry" "$file"
    ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
    ${pkgs.libnotify}/bin/notify-send -i "$file" "Captura de Tela" "Recorte salvo em Pictures/Screenshots e copiado."
  '';
in
{
  options.desktop.hyprland = {
    enable = mkOption {
      type = bool;
      default = (desktop == "hyprland");
      description = "Enable Hyprland dynamic tiling Wayland compositor";
    };

    extraConfig = mkOption {
      type = str;
      default = "";
      description = "Additional Hyprland configuration lines to append";
    };

    monitors = mkOption {
      type = listOf str;
      default = [ ",preferred,auto,1" ];
      description = "Hyprland monitor configurations";
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      xwayland.enable = true;
      configType = "hyprlang";

      settings = {
        "$mainMod" = "SUPER";

        monitor = cfg.monitors;

        env = [
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "QT_QPA_PLATFORM,wayland;xcb"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          "GDK_BACKEND,wayland,x11,*"
          "CLUTTER_BACKEND,wayland"
          "SDL_VIDEODRIVER,wayland"
          "MOZ_ENABLE_WAYLAND,1"
        ];

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "rgba(cba6f7ee) rgba(89b4faee) 45deg"; # Mauve to Blue gradient
          "col.inactive_border" = "rgba(313244aa)"; # Surface0
          layout = "dwindle";
          allow_tearing = false;
        };

        cursor = {
          no_hardware_cursors = true;
        };

        render = {
          direct_scanout = 0;
        };

        debug = {
          vfr = false;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          disable_watchdog_warning = true;
          vrr = 0;
        };

        ecosystem = {
          no_update_news = true;
          no_donation_nag = true;
        };

        decoration = {
          rounding = 10;
          active_opacity = 0.98;
          inactive_opacity = 0.90;
          fullscreen_opacity = 1.0;

          blur = {
            enabled = true;
            size = 6;
            passes = 2;
            new_optimizations = true;
            xray = false;
          };

          shadow = {
            enabled = true;
            range = 15;
            render_power = 3;
            color = "rgba(17, 17, 27, 0.65)"; # Catppuccin Crust shadow
          };

          dim_inactive = true;
          dim_strength = 0.12;
        };

        animations = {
          enabled = true;
          bezier = [
            "fastBezier, 0.05, 0.9, 0.1, 1.05"
            "overshot, 0.13, 0.99, 0.29, 1.1"
          ];
          animation = [
            "windows, 1, 4, fastBezier, slide"
            "windowsOut, 1, 4, default, popin 80%"
            "border, 1, 6, default"
            "borderangle, 1, 6, default"
            "fade, 1, 4, default"
            "workspaces, 1, 5, overshot, slide"
          ];
        };

        input = {
          kb_layout = "br,us";
          kb_options = "grp:alt_shift_toggle";
          follow_mouse = 1;
          sensitivity = 0;

          touchpad = {
            natural_scroll = true;
            tap-to-click = true;
            disable_while_typing = true;
          };
        };

        gesture = [
          "3, horizontal, workspace"
        ];

        dwindle = {
          preserve_split = true;
        };

        exec-once = [
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE"
          "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE"
          "${pkgs.waybar}/bin/waybar"
          "${pkgs.dunst}/bin/dunst"
          "${pkgs.hypridle}/bin/hypridle"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
          "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
          "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"
        ];

        bind = [
          # Aplicações e Launcher
          "$mainMod, RETURN, exec, ${pkgs.alacritty}/bin/alacritty"
          "$mainMod, SPACE, exec, ${pkgs.rofi}/bin/rofi -show drun"
          "$mainMod, D, exec, ${pkgs.rofi}/bin/rofi -show drun"
          "$mainMod, E, exec, ${pkgs.thunar}/bin/thunar"
          "$mainMod, V, exec, hypr-cliphist"
          "$mainMod, L, exec, ${pkgs.hyprlock}/bin/hyprlock"

          # Gerenciamento de Janelas
          "$mainMod, Q, killactive,"
          "$mainMod, C, killactive,"
          "$mainMod, F, fullscreen, 0"
          "$mainMod SHIFT, SPACE, togglefloating,"
          "$mainMod, P, pseudo,"
          "$mainMod, J, layoutmsg, togglesplit"

          # Navegação de Foco (Setas e Vim Keys)
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          "$mainMod, h, movefocus, l"
          "$mainMod, l, movefocus, r"
          "$mainMod, k, movefocus, u"

          # Movimentação de Janelas
          "$mainMod SHIFT, left, movewindow, l"
          "$mainMod SHIFT, right, movewindow, r"
          "$mainMod SHIFT, up, movewindow, u"
          "$mainMod SHIFT, down, movewindow, d"
          "$mainMod SHIFT, h, movewindow, l"
          "$mainMod SHIFT, l, movewindow, r"
          "$mainMod SHIFT, k, movewindow, u"

          # Alternar Workspaces (1 a 10)
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"

          # Mover Janela para Workspace (1 a 10)
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"

          # Capturas de Tela
          ", Print, exec, ${screenshotFull}"
          "SHIFT, Print, exec, ${screenshotArea}"
          "$mainMod SHIFT, S, exec, ${screenshotArea}"

          # Menu de Energia / Logout
          "$mainMod, ESCAPE, exec, hyprland-power-menu"
          "$mainMod SHIFT, E, exec, hyprland-power-menu"
        ];

        bindl = [
          # Teclas de Mídia e Áudio
          ", XF86AudioMute, exec, ${pkgs.pamixer}/bin/pamixer -t"
          ", XF86AudioMicMute, exec, ${pkgs.pamixer}/bin/pamixer --default-source -t"
          ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
          ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
          ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
        ];

        binde = [
          # Volume e Brilho com repetição contínua
          ", XF86AudioRaiseVolume, exec, ${pkgs.pamixer}/bin/pamixer -i 5"
          ", XF86AudioLowerVolume, exec, ${pkgs.pamixer}/bin/pamixer -d 5"
          ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%+"
          ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        windowrule = [
          # Diálogos de Seleção de Pastas e Arquivos -> Flutuantes e Centralizados
          "match:class ^(xdg-desktop-portal.*)$, float 1"
          "match:class ^(xdg-desktop-portal.*)$, center 1"
          "match:class ^(pavucontrol)$, float 1"
          "match:class ^(pavucontrol)$, center 1"
          "match:class ^(pavucontrol)$, size 680 480"
          "match:class ^(blueman-manager)$, float 1"
          "match:class ^(blueman-manager)$, center 1"
          "match:class ^(nm-connection-editor)$, float 1"
          "match:class ^(nm-connection-editor)$, center 1"
          "match:class ^(galculator)$, float 1"
          "match:class ^(galculator)$, center 1"
          "match:class ^(org.gnome.FileRoller)$, float 1"
          "match:class ^(org.gnome.FileRoller)$, center 1"

          # Títulos bilíngues de seleção de arquivo
          "match:title ^(Open Folder|Abrir pasta|Open File|Abrir Arquivo|Select a folder|Selecionar pasta|Save As|Salvar como)$, float 1"
          "match:title ^(Open Folder|Abrir pasta|Open File|Abrir Arquivo|Select a folder|Selecionar pasta|Save As|Salvar como)$, center 1"
          "match:title ^(Open Folder|Abrir pasta|Open File|Abrir Arquivo|Select a folder|Selecionar pasta|Save As|Salvar como)$, size 850 550"

          # Picture-in-Picture
          "match:title ^(Picture-in-Picture)$, float 1"
          "match:title ^(Picture-in-Picture)$, pin 1"
          "match:title ^(Picture-in-Picture)$, size 640 360"
        ];
      };

      extraConfig = cfg.extraConfig;
    };
  };
}
