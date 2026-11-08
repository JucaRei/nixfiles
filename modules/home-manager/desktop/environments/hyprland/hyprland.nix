{
  config,
  lib,
  pkgs,
  desktop ? null,
  nixGLWrapper ? lib.id,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.hyprland;
  themeLib = config.desktop.theme.lib;
  c = config.desktop.theme.colors;
  isNoctalia = (config.desktop.wayland.shell or "traditional") == "noctalia";
  isApple = (config.home.keyboard.model or "") == "apple";

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

  screenshotPick = pkgs.writeShellScript "hypr-screenshot-pick" ''
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
    geometry="$(${pkgs.slurp}/bin/slurp -o)"
    [ -z "$geometry" ] && exit 0
    ${pkgs.grim}/bin/grim -g "$geometry" "$file"
    ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
    ${pkgs.libnotify}/bin/notify-send -i "$file" "Captura de Tela" "Monitor capturado salvo em Pictures/Screenshots e copiado."
  '';

  kbdBrightnessOsd = pkgs.writeShellScript "hypr-kbd-brightness-osd" ''
    # Identificar dispositivo de iluminação de teclado (MacBook smc::kbd_backlight ou similar)
    dev="smc::kbd_backlight"
    if ! ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" info >/dev/null 2>&1; then
      dev=$(${pkgs.brightnessctl}/bin/brightnessctl --list 2>/dev/null | grep -E -m1 "kbd_backlight|keyboard" | cut -d\' -f2 || true)
    fi

    if [ -n "$dev" ]; then
      case "$1" in
        up)
          prev=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set +5% >/dev/null 2>&1
          curr=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          if [ "$prev" = "$curr" ]; then
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set +1 >/dev/null 2>&1
          fi
          ;;
        down)
          prev=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 5%- >/dev/null 2>&1
          curr=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          if [ "$prev" = "$curr" ]; then
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 1- >/dev/null 2>&1
          fi
          ;;
        toggle)
          curr=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" -m 2>/dev/null | cut -d, -f4 | tr -d '%' | head -n1)
          if [ "$curr" -gt 0 ] 2>/dev/null; then
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 0%
          else
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 50%
          fi
          ;;
      esac

      val=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" -m 2>/dev/null | cut -d, -f4 | tr -d '%' | head -n1)
      if [ -n "$val" ]; then
        ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -h int:value:"$val" -t 1500 "Luz do Teclado: $val%"
      fi
    else
      # Teclados externos (Logitech MX Keys / sem interface direta em /sys/class/leds)
      SOLAAR_CMD=""
      if command -v solaar >/dev/null 2>&1; then
        SOLAAR_CMD="solaar"
      elif [ -x "${pkgs.solaar}/bin/solaar" ]; then
        SOLAAR_CMD="${pkgs.solaar}/bin/solaar"
      fi

      if [ -n "$SOLAAR_CMD" ]; then
        case "$1" in
          up|toggle)
            "$SOLAAR_CMD" config "MX Keys" backlight true 2>/dev/null || \
            "$SOLAAR_CMD" config active backlight true 2>/dev/null || \
            "$SOLAAR_CMD" config 1 backlight true 2>/dev/null || true
            ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (MX Keys): Aumentar / Ativada"
            ;;
          down)
            "$SOLAAR_CMD" config "MX Keys" backlight false 2>/dev/null || \
            "$SOLAAR_CMD" config active backlight false 2>/dev/null || \
            "$SOLAAR_CMD" config 1 backlight false 2>/dev/null || true
            ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (MX Keys): Diminuir / Desativada"
            ;;
        esac
      else
        case "$1" in
          up)   ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (F4 / MX Keys): Aumentar" ;;
          down) ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (F3 / MX Keys): Diminuir" ;;
          toggle) ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (MX Keys): Alternar" ;;
        esac
      fi
    fi
  '';

  monBrightnessOsd = pkgs.writeShellScript "hypr-mon-brightness-osd" ''
    case "$1" in
      up)
        prev=$(${pkgs.brightnessctl}/bin/brightnessctl get 2>/dev/null)
        ${pkgs.brightnessctl}/bin/brightnessctl set +2% >/dev/null 2>&1
        curr=$(${pkgs.brightnessctl}/bin/brightnessctl get 2>/dev/null)
        if [ "$prev" = "$curr" ]; then
          ${pkgs.brightnessctl}/bin/brightnessctl set +1 >/dev/null 2>&1
        fi
        ;;
      down)
        prev=$(${pkgs.brightnessctl}/bin/brightnessctl get 2>/dev/null)
        ${pkgs.brightnessctl}/bin/brightnessctl set 2%- >/dev/null 2>&1
        curr=$(${pkgs.brightnessctl}/bin/brightnessctl get 2>/dev/null)
        if [ "$prev" = "$curr" ]; then
          ${pkgs.brightnessctl}/bin/brightnessctl set 1- >/dev/null 2>&1
        fi
        ;;
    esac
    val=$(${pkgs.brightnessctl}/bin/brightnessctl -m | cut -d, -f4 | tr -d '%')
    if [ -n "$val" ]; then
      ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "display-brightness" -r 9992 -h int:value:"$val" -t 1500 "Brilho da Tela: $val%"
    fi
  '';
in
{
  options.desktop.hyprland = {
    enable = lib.my.mkBool (desktop == "hyprland") "Enable Hyprland dynamic tiling Wayland compositor";

    extraConfig = lib.my.mkStr "" "Additional Hyprland configuration lines to append";

    monitors = lib.my.mkListOf lib.types.str [ ",preferred,auto,1" ] "Hyprland monitor configurations";

    keyboard = {
      layout = lib.my.mkStr (
        if config.home.keyboard != null && config.home.keyboard.layout != null then
          config.home.keyboard.layout
        else
          "br,us"
      ) "Hyprland keyboard layout (defaults to home.keyboard.layout)";

      variant = lib.my.mkStr (
        if config.home.keyboard != null && config.home.keyboard.variant != null then
          config.home.keyboard.variant
        else
          ""
      ) "Hyprland keyboard variant (defaults to home.keyboard.variant)";

      model = lib.my.mkStr (
        if config.home.keyboard != null && config.home.keyboard.model != null then
          config.home.keyboard.model
        else
          ""
      ) "Hyprland keyboard model (defaults to home.keyboard.model)";

      options = lib.my.mkStr (
        if config.home.keyboard != null && config.home.keyboard.options != [ ] then
          lib.concatStringsSep "," config.home.keyboard.options
        else
          ""
      ) "Hyprland keyboard options (defaults to home.keyboard.options)";
    };

    modifierKey = lib.my.mkStr (config.desktop.modifierKey or "Super"
    ) "Tecla modificadora principal do Hyprland (ex: 'SUPER', 'ALT', 'CTRL').";
  };

  config =
    let
      normMod =
        let
          k = lib.toLower (cfg.modifierKey or "super");
        in
        if k == "super" || k == "mod4" then
          "Super"
        else if k == "alt" || k == "mod1" then
          "Alt"
        else if k == "ctrl" || k == "control" then
          "Ctrl"
        else
          "Super";

      mainMod =
        if normMod == "Alt" then
          "ALT"
        else if normMod == "Ctrl" then
          "CTRL"
        else
          "SUPER";

      altMod = if mainMod == "ALT" then "SUPER" else "ALT";
      ctrlMod = if mainMod == "CTRL" then "SUPER" else "CTRL";
    in
    mkIf cfg.enable {
      wayland.windowManager.hyprland = {
        enable = true;
        package = nixGLWrapper pkgs.hyprland;
        xwayland.enable = true;
        configType = "hyprlang";

        settings = {
          "$mainMod" = mainMod;

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
            "col.active_border" = "${themeLib.rgba c.accent "ee"} ${themeLib.rgba c.blue "ee"} 45deg";
            "col.inactive_border" = "${themeLib.rgba c.surfaceAlt "aa"}";
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
              color = themeLib.cssRgba c.bgDark 0.65;
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
            kb_layout = cfg.keyboard.layout;
            kb_variant = cfg.keyboard.variant;
            kb_model = cfg.keyboard.model;
            kb_options = cfg.keyboard.options;
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
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
            "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
            "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"
          ]
          ++ (
            if isNoctalia then
              [
                "${pkgs.noctalia}/bin/noctalia"
              ]
            else
              [
                "${pkgs.waybar}/bin/waybar"
                "${pkgs.dunst}/bin/dunst"
                "${pkgs.hypridle}/bin/hypridle"
              ]
          );

          windowrule = import ./_hyprland-rules.nix;
        }
        // (import ./_hyprland-binds.nix {
          inherit
            pkgs
            config
            isNoctalia
            isApple
            altMod
            ctrlMod
            screenshotFull
            screenshotArea
            screenshotPick
            kbdBrightnessOsd
            monBrightnessOsd
            ;
        });

        inherit (cfg) extraConfig;
      };
    };
}
