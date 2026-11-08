{
  lib,
  colors,
  pillsContext,
}:
let
  inherit (pillsContext)
    isPills
    hasTray
    wsColor
    focusedWsColor
    focusedNumColor
    statsColor
    cpuIconColor
    memIconColor
    tempIconColor
    diskIconColor
    netspeedColor
    netspeedAccent
    dateColor
    dateAccent
    trayColor
    trayAccent
    wsGlyphs
    statsGlyphs
    netspeedGlyphs
    dateGlyphs
    trayGlyphs
    ;

  pillModuleOverrides =
    lib.optionalAttrs isPills {
      "module/bspwm" = {
        ws-icon-0 = "1;%{F${colors.yellow-alt}}1%{F-}";
        ws-icon-1 = "2;%{F${colors.coral}}2%{F-}";
        ws-icon-2 = "3;%{F${colors.mint}}3%{F-}";
        ws-icon-3 = "4;%{F${colors.nord}}4%{F-}";
        ws-icon-4 = "5;%{F${colors.green-alt}}5%{F-}";
        ws-icon-5 = "6;%{F${colors.yellow-alt}}6%{F-}";
        ws-icon-6 = "7;%{F${colors.coral}}7%{F-}";
        ws-icon-7 = "8;%{F${colors.mint}}8%{F-}";
        ws-icon-8 = "9;%{F${colors.nord}}9%{F-}";
        ws-icon-9 = "0;%{F${colors.green-alt}}10%{F-}";
        ws-icon-10 = "10;%{F${colors.green-alt}}10%{F-}";
        ws-icon-default = "%name%";

        # Workspace focado: Pac-Man (󰮯) e número com cor amena e elegante no fundo ativo
        label-focused = "%{T2}%{F${colors.dark}}󰮯 %{F-}%{T-}%{T3}%{F${focusedNumColor}}%name%%{F-}%{T-}";
        label-focused-foreground = focusedNumColor;
        label-focused-background = focusedWsColor;
        label-focused-padding = 1;
        label-focused-margin = 0;

        # Workspace ocupado (com janelas): número colorido pastel no fundo padrão da cápsula
        label-occupied = "%{T3}%icon%%{T-}";
        label-occupied-foreground = colors.text;
        label-occupied-background = wsColor;
        label-occupied-padding = 1;
        label-occupied-margin = 0;

        # Workspace com urgência / alerta: fantasma do Pac-Man (󰊠) em vermelho
        label-urgent = "%{T2}%{F${colors.red}}󰊠 %{F-}%{T-}%{T3}%icon%%{T-}";
        label-urgent-foreground = colors.nord;
        label-urgent-background = wsColor;
        label-urgent-padding = 1;
        label-urgent-margin = 0;

        # Workspace vazio: número atenuado e sutil (%name%), sem cor de ícone ativa
        label-empty = "%{T3}%name%%{T-}";
        label-empty-foreground = colors.muted;
        label-empty-background = wsColor;
        label-empty-padding = 1;
        label-empty-margin = 0;

        label-separator = "";
        label-separator-background = wsColor;
      };

      # Módulos dedicados para cada seção da barra, sincronizando glifos e cores com perfeição
      "module/encap-ws-left" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}${wsGlyphs.left}%{T-}";
        label-foreground = wsColor;
        format-margin = 0;
        format-padding = 0;
      };
      "module/encap-ws-right" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}${wsGlyphs.right}%{T-}";
        label-foreground = wsColor;
        format-margin = 0;
        format-padding = 0;
      };
      "module/encap-stats-left" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}${statsGlyphs.left}%{T-}";
        label-foreground = statsColor;
        format-margin = 0;
        format-padding = 0;
      };
      "module/encap-stats-right" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}${statsGlyphs.right}%{T-}";
        label-foreground = statsColor;
        format-margin = 0;
        format-padding = 0;
      };
      "module/encap-netspeed-left" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}${netspeedGlyphs.left}%{T-}";
        label-foreground = netspeedColor;
        format-margin = 0;
        format-padding = 0;
      };
      "module/encap-netspeed-right" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}${netspeedGlyphs.right}%{T-}";
        label-foreground = netspeedColor;
        format-margin = 0;
        format-padding = 0;
      };
      "module/encap-date-left" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}${dateGlyphs.left}%{T-}";
        label-foreground = dateColor;
        format-margin = 0;
        format-padding = 0;
      };
      "module/encap-date-right" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}${dateGlyphs.right}%{T-}";
        label-foreground = dateColor;
        format-margin = 0;
        format-padding = 0;
      };
      "module/encap-tray-left" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}${trayGlyphs.left}%{T-}";
        label-foreground = trayColor;
        format-margin = 0;
        format-padding = 0;
      };
      "module/encap-tray-right" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}${trayGlyphs.right}%{T-}";
        label-foreground = trayColor;
        format-margin = 0;
        format-padding = 0;
      };

      # Sobrescrita direta de compatibilidade para módulos shape-left/shape-right manuais
      "module/shape-left" = {
        label = "%{T5}%{T-}";
        label-foreground = statsColor;
        format-margin = 0;
        format-padding = 0;
      };
      "module/shape-right" = {
        label = "%{T5}%{T-}";
        label-foreground = statsColor;
        format-margin = 0;
        format-padding = 0;
      };
      "module/shapes-left" = {
        label = "%{T5}%{T-}";
        label-foreground = statsColor;
        format-margin = 0;
        format-padding = 0;
      };
      "module/shapes-right" = {
        label = "%{T5}%{T-}";
        label-foreground = statsColor;
        format-margin = 0;
        format-padding = 0;
      };

      "module/cpu" = {
        format = "<label>";
        format-prefix = "";
        format-background = statsColor;
        format-margin = 0;
        format-padding = 0;
        label = " %{T2}%{F${cpuIconColor}} %{F-}%{T-}%percentage%% ";
        label-foreground = colors.text-alt;
        label-background = statsColor;
        label-padding = 0;
        label-margin = 0;
      };

      "module/memory" = {
        format = "<label>";
        format-prefix = "";
        format-background = statsColor;
        format-margin = 0;
        format-padding = 0;
        label = " %{T2}%{F${memIconColor}} %{F-}%{T-}%percentage_used%% ";
        label-foreground = colors.text-alt;
        label-background = statsColor;
        label-padding = 0;
        label-margin = 0;
      };

      "module/temperature" = {
        type = "internal/temperature";
        thermal-zone = 0;
        warn-temperature = 75;
        format = "<label>";
        format-warn = "<label-warn>";
        format-prefix = "";
        format-background = statsColor;
        format-warn-background = statsColor;
        format-margin = 0;
        format-padding = 0;
        format-warn-padding = 0;
        label = " %{T2}%{F${tempIconColor}} %{F-}%{T-}%temperature-c% ";
        label-warn = " %{T2}%{F${colors.red}} %{F-}%{T-}%temperature-c% ";
        label-foreground = colors.text-alt;
        label-warn-foreground = colors.red;
        label-background = statsColor;
        label-warn-background = statsColor;
        label-padding = 0;
        label-warn-padding = 0;
        label-margin = 0;
      };

      "module/pulseaudio" = {
        label-foreground = colors.red-alt;
      };

      "module/bluetooth" = {
        label-foreground = colors.blue-alt;
      };

      "module/backlight" = {
        format = "<label>";
        format-prefix = "";
      };

      "module/battery" = {
        ramp-capacity-foreground = colors.bat-green;
        animation-charging-foreground = colors.bat-charging;
        label-charging-foreground = colors.text-alt;
        label-discharging-foreground = colors.text-alt;
        label-full-foreground = colors.text-alt;
      };

      "module/keyboard" = {
        format-prefix-foreground = colors.text-alt;
        label-layout-foreground = colors.text-alt;
      };

      "module/date" = {
        interval = 1;
        format = "<label>";
        format-prefix = "";
        format-prefix-foreground = dateAccent;
        format-background = dateColor;
        format-margin = 0;
        format-padding = 0;
        date = "%{F${dateAccent}}  %H:%M:%S%{F-}";
        date-alt = "%{F${dateAccent}}  %a, %d %b %Y  %{F${dateAccent}}  %H:%M:%S%{F-}";
        time = "";
        time-alt = "";
        label = " %date% ";
        label-foreground = dateAccent;
        label-background = dateColor;
        label-padding = 0;
        label-margin = 0;
      };

      "module/network" = {
        label-foreground = colors.green-alt;
      };

      "module/netspeed" = {
        format = "<label>";
        format-background = netspeedColor;
        format-margin = 0;
        format-padding = 0;
        label = " %output% ";
        label-foreground = netspeedAccent;
        label-background = netspeedColor;
        label-padding = 0;
        label-margin = 0;
      };

      "module/disk" = {
        spacing = 0;
        format-mounted = "<label-mounted>";
        format-mounted-prefix = "";
        format-mounted-background = statsColor;
        format-mounted-margin = 0;
        format-mounted-padding = 0;
        label-mounted = " %{T2}%{F${diskIconColor}} %{F-}%{T-}%free% ";
        label-mounted-foreground = colors.text-alt;
        label-mounted-background = statsColor;
        label-mounted-padding = 0;
        label-mounted-margin = 0;
      };

      "module/uptime" = {
        label-foreground = colors.mint;
      };

      "module/bsp-layout" = {
        label-foreground = colors.coral;
      };

      "module/media" = {
        label-foreground = colors.purple;
      };

      "module/minimized" = {
        label-foreground = colors.yellow-alt;
      };

      "module/powermenu" = {
        label = "";
        label-foreground = colors.red-alt;
      };

      "module/notifications" = {
        label-foreground = colors.text-alt;
      };
    }
    // lib.optionalAttrs hasTray {
      "module/tray" = {
        format-background = trayColor;
        label-background = trayColor;
        label-foreground = trayAccent;
      };
    };

in
pillModuleOverrides
