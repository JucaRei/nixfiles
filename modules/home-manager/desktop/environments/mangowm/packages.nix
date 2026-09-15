{
  config,
  lib,
  pkgs,
  inputs,
  desktop ? null,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.mangowm;

  mangoPkg =
    if (inputs ? mangowm && inputs.mangowm ? packages && inputs.mangowm.packages ? ${pkgs.stdenv.hostPlatform.system}) then
      inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.mango
    else
      pkgs.emptyDirectory;
  mangoReload = pkgs.writeShellScriptBin "mango-reload" ''
    if [ -z "''${MANGO_INSTANCE_SIGNATURE:-}" ]; then
      export MANGO_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/mango-*.sock 2>/dev/null | head -n1 || true)
    fi
    mmsg dispatch reload_config 2>/dev/null || true
    pkill -SIGUSR2 waybar 2>/dev/null || true
    ${pkgs.libnotify}/bin/notify-send -u low -i "preferences-desktop" "MangoWM" "Configurações e Waybar recarregados!"
  '';

  mangoToggleOuterGaps = pkgs.writeShellScriptBin "mango-toggle-outer-gaps" ''
    if [ -z "''${MANGO_INSTANCE_SIGNATURE:-}" ]; then
      export MANGO_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/mango-*.sock 2>/dev/null | head -n1 || true)
    fi
    STATE_FILE="$HOME/.cache/mango_gaps_mode"
    mkdir -p "$HOME/.cache"
    if [ -f "$STATE_FILE" ]; then
      rm -f "$STATE_FILE"
      mmsg dispatch setgappo,12,12 2>/dev/null || true
      ${pkgs.libnotify}/bin/notify-send -u low "MangoWM" "Modo Normal: Gaps externos (12px)"
    else
      touch "$STATE_FILE"
      mmsg dispatch setgappo,400,12 2>/dev/null || true
      ${pkgs.libnotify}/bin/notify-send -u low "MangoWM" "Modo Foco: Gaps externos expandidos (400px)"
    fi
  '';
  mangoLayoutSwitcher = pkgs.writeShellScriptBin "mango-layout-switcher" ''
    if [ -z "''${MANGO_INSTANCE_SIGNATURE:-}" ]; then
      export MANGO_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/mango-*.sock 2>/dev/null | head -n1 || true)
    fi

    declare -A LAYOUT_NAMES=(
      [T]="Tile"
      [S]="Scroller"
      [G]="Grid"
      [M]="Monocle"
      [K]="Deck"
      [CT]="Center Tile"
      [RT]="Right Tile"
      [VS]="Vert Scroller"
      [VT]="Vert Tile"
      [VG]="Vert Grid"
      [VK]="Vert Deck"
      [DW]="Dwindle"
      [F]="Fair"
      [VF]="Vert Fair"
      [TG]="TGMix"
    )

    declare -A LAYOUT_ICONS=(
      [T]="󰕰"
      [S]="󰹑"
      [G]="󰝘"
      [M]="󰍹"
      [K]="󰓩"
      [CT]="󰕲"
      [RT]="󰕳"
      [VS]="󰹒"
      [VT]="󰕴"
      [VG]="󰝙"
      [VK]="󰓪"
      [DW]="󰕯"
      [F]="󰕮"
      [VF]="󰕬"
      [TG]="󰕱"
    )

    state=$(mmsg get all-monitors 2>/dev/null || true)
    if [ -z "$state" ] || echo "$state" | grep -q '"error"'; then
      echo '{"text":"󰕰 Mango","tooltip":"MangoWM não detectado ou inativo"}'
      exit 0
    fi

    code=$(echo "$state" | ${pkgs.jq}/bin/jq -r '.monitors[] | select(.active) | .layout_symbol // empty' 2>/dev/null | head -n1 || true)
    if [ -z "$code" ]; then
      code=$(echo "$state" | ${pkgs.jq}/bin/jq -r '.monitors[0].layout_symbol // empty' 2>/dev/null || true)
    fi

    if [ -z "$code" ] || [ -z "''${LAYOUT_NAMES[$code]+x}" ]; then
      echo "{\"text\":\"󰕰 ''${code:-Tile}\",\"tooltip\":\"Layout atual: ''${code:-Desconhecido}\",\"class\":\"other\"}"
      exit 0
    fi

    name="''${LAYOUT_NAMES[$code]}"
    icon="''${LAYOUT_ICONS[$code]:-󰕰}"

    echo "{\"text\":\"$icon $name\",\"tooltip\":\"Layout do MangoWM: $name ($code)\nClique: Menu de Seleção | Dir: Alternar\",\"class\":\"$code\"}"
  '';

  mangoLayoutPicker = pkgs.writeShellScriptBin "mango-layout-picker" ''
    if [ -z "''${MANGO_INSTANCE_SIGNATURE:-}" ]; then
      export MANGO_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/mango-*.sock 2>/dev/null | head -n1 || true)
    fi

    options="󰹑 Scroller (S)\n󰕰 Tile (T)\n󰕲 Center Tile (CT)\n󰝘 Grid (G)\n󰍹 Monocle (M)\n󰓩 Deck (K)\n󰕳 Right Tile (RT)\n󰹒 Vertical Scroller (VS)\n󰕴 Vertical Tile (VT)\n󰝙 Vertical Grid (VG)\n󰓪 Vertical Deck (VK)\n󰕯 Dwindle (DW)\n󰕮 Fair (F)\n󰕬 Vertical Fair (VF)"

    dmenu_sock=$(ls /run/user/$(id -u)/noctalia-dmenu-*.sock 2>/dev/null | head -n1 || true)

    if [ -n "$dmenu_sock" ] && [ -S "$dmenu_sock" ] && command -v noctalia >/dev/null 2>&1; then
      chosen=$(printf "%b" "$options" | noctalia dmenu -p "Layout MangoWM")
    else
      chosen=$(printf "%b" "$options" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󱗼 Layout Mango " -theme-str '
        * {
          bg-col: #1e1e2e;
          bg-col-light: #181825;
          border-col: #cba6f7;
          selected-col: #313244;
          fg-col: #cdd6f4;
          grey: #6c7086;
          font: "Inter 11";
        }
        window {
          width: 360px;
          height: 520px;
          border: 2px;
          border-color: #cba6f7;
          border-radius: 12px;
          background-color: #1e1e2e;
        }
        mainbox {
          background-color: #1e1e2e;
          padding: 12px;
        }
        inputbar {
          children: [prompt, entry];
          background-color: #181825;
          border-radius: 8px;
          padding: 6px 10px;
          margin: 0px 0px 8px 0px;
        }
        prompt {
          background-color: #cba6f7;
          padding: 4px 8px;
          text-color: #11111b;
          border-radius: 6px;
          margin: 0px 8px 0px 0px;
        }
        entry {
          padding: 4px;
          text-color: #cdd6f4;
          background-color: transparent;
          placeholder-color: #6c7086;
        }
        listview {
          border: 0px;
          padding: 4px 0px 0px;
          margin: 0px;
          columns: 1;
          lines: 14;
          background-color: #1e1e2e;
        }
        element {
          padding: 6px 10px;
          background-color: #1e1e2e;
          text-color: #cdd6f4;
          border-radius: 6px;
        }
        element selected {
          background-color: #313244;
          text-color: #cba6f7;
        }
        element-text, element-icon {
          background-color: inherit;
          text-color: inherit;
        }
      ')
    fi

    case "$chosen" in
      *"Scroller (S)"*)           mmsg dispatch setlayout,scroller >/dev/null 2>&1 ;;
      *"Tile (T)"*)               mmsg dispatch setlayout,tile >/dev/null 2>&1 ;;
      *"Center Tile (CT)"*)       mmsg dispatch setlayout,center_tile >/dev/null 2>&1 ;;
      *"Grid (G)"*)               mmsg dispatch setlayout,grid >/dev/null 2>&1 ;;
      *"Monocle (M)"*)            mmsg dispatch setlayout,monocle >/dev/null 2>&1 ;;
      *"Deck (K)"*)               mmsg dispatch setlayout,deck >/dev/null 2>&1 ;;
      *"Right Tile (RT)"*)        mmsg dispatch setlayout,right_tile >/dev/null 2>&1 ;;
      *"Vertical Scroller (VS)"*) mmsg dispatch setlayout,vertical_scroller >/dev/null 2>&1 ;;
      *"Vertical Tile (VT)"*)     mmsg dispatch setlayout,vertical_tile >/dev/null 2>&1 ;;
      *"Vertical Grid (VG)"*)     mmsg dispatch setlayout,vertical_grid >/dev/null 2>&1 ;;
      *"Vertical Deck (VK)"*)     mmsg dispatch setlayout,vertical_deck >/dev/null 2>&1 ;;
      *"Dwindle (DW)"*)           mmsg dispatch setlayout,dwindle >/dev/null 2>&1 ;;
      *"Fair (F)"*)               mmsg dispatch setlayout,fair >/dev/null 2>&1 ;;
      *"Vertical Fair (VF)"*)     mmsg dispatch setlayout,vertical_fair >/dev/null 2>&1 ;;
    esac
    pkill -RTMIN+8 waybar 2>/dev/null || true
  '';
in
{
  options.desktop.mangowm = {
    enable = mkOption {
      type = bool;
      default = (desktop == "mangowm" || desktop == "mango");
      description = "Enable MangoWM Wayland dynamic tiling compositor based on dwl";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mangoPkg
      mangoReload
      mangoToggleOuterGaps
      mangoLayoutSwitcher
      mangoLayoutPicker
      wl-clipboard
      cliphist
      pamixer
      playerctl
      brightnessctl
      libnotify
      grim
      slurp
      hicolor-icon-theme
      adwaita-icon-theme
    ];

    home.file = {
      # Wrapper de inicialização com carregamento do ambiente Nix e drivers gráficos nativos
      ".local/bin/start-mango" = {
        executable = true;
        text = ''
          #!/bin/sh
          # Limpa variáveis herdadas do compositor do Display Manager (ex: Weston no SDDM)
          unset WAYLAND_DISPLAY
          unset DISPLAY

          if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
            . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          fi
          if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
            . "$HOME/.nix-profile/etc/profile.d/nix.sh"
          fi
          if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
            . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
          fi

          export XDG_CURRENT_DESKTOP=mango
          export XDG_SESSION_DESKTOP=mango
          export XDG_SESSION_TYPE=wayland
          export NIXOS_OZONE_WL=1
          export MOZ_ENABLE_WAYLAND=1
          export _JAVA_AWT_WM_NONREPARENTING=1
          export QT_QPA_PLATFORM="wayland;xcb"
          export GDK_BACKEND="wayland,x11"
          export CLUTTER_BACKEND="wayland"
          export SDL_VIDEODRIVER="wayland"

          # Tema GTK escuro unificado
          export GTK_THEME="catppuccin-mocha-blue-standard+rimless"

          # Drivers Mesa nativos para aceleração por hardware em distros não-NixOS
          export GBM_BACKENDS_PATH="${pkgs.mesa}/lib/gbm:/usr/lib64/gbm''${GBM_BACKENDS_PATH:+:$GBM_BACKENDS_PATH}"
          export LIBGL_DRIVERS_PATH="${pkgs.mesa}/lib/dri:/usr/lib64/dri''${LIBGL_DRIVERS_PATH:+:$LIBGL_DRIVERS_PATH}"
          export __EGL_VENDOR_LIBRARY_DIRS="${pkgs.mesa}/share/glvnd/egl_vendor.d:/usr/share/glvnd/egl_vendor.d''${__EGL_VENDOR_LIBRARY_DIRS:+:$__EGL_VENDOR_LIBRARY_DIRS}"

          # Aceleração de hardware VA-API para Intel Sandy Bridge (i965)
          export LIBVA_DRIVER_NAME="i965"
          export LIBVA_DRIVERS_PATH="${pkgs.intel-vaapi-driver}/lib/dri:/usr/lib64/dri''${LIBVA_DRIVERS_PATH:+:$LIBVA_DRIVERS_PATH}"

          # Propagação do ambiente gráfico para o D-Bus e Systemd do usuário
          systemctl --user set-environment GBM_BACKENDS_PATH="$GBM_BACKENDS_PATH" LIBGL_DRIVERS_PATH="$LIBGL_DRIVERS_PATH" __EGL_VENDOR_LIBRARY_DIRS="$__EGL_VENDOR_LIBRARY_DIRS" LIBVA_DRIVER_NAME="$LIBVA_DRIVER_NAME" LIBVA_DRIVERS_PATH="$LIBVA_DRIVERS_PATH" GTK_THEME="$GTK_THEME" 2>/dev/null || true
          if command -v dbus-update-activation-environment >/dev/null 2>&1; then
            dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE GTK_THEME
          fi
          systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE GTK_THEME 2>/dev/null || true

          exec ${mangoPkg}/bin/mango "$@"
        '';
      };

      # Entrada de sessão para Display Managers (SDDM, GDM)
      ".local/share/wayland-sessions/mango.desktop".text = ''
        [Desktop Entry]
        Name=Mango
        Comment=Mango Wayland Compositor based on dwl
        Exec=${config.home.homeDirectory}/.local/bin/start-mango
        Type=Application
        DesktopNames=mango
      '';

      # Configuração dos Portals XDG para o Mango
      ".config/xdg-desktop-portal/mango-portals.conf".text = ''
        [preferred]
        default=wlr;gtk
      '';
    };
  };
}
