{
  pkgs,
  colors,
  scripts,
  ...
}:
{
  # --- Workspaces do BSPWM (Badges Modernos Estilo Waybar) ---
  "module/bspwm" = {
    type = "internal/bspwm";
    pin-workspaces = true;
    enable-click = true;
    enable-scroll = true;
    reverse-scroll = false;
    inline-mode = false;
    fuzzy-match = true;

    # Mapeamento dos workspaces de 1 a 10 em numerais Kanji (Japanese numerals)
    ws-icon-0 = "1;一";
    ws-icon-1 = "2;二";
    ws-icon-2 = "3;三";
    ws-icon-3 = "4;四";
    ws-icon-4 = "5;五";
    ws-icon-5 = "6;六";
    ws-icon-6 = "7;七";
    ws-icon-7 = "8;八";
    ws-icon-8 = "9;九";
    ws-icon-9 = "0;十";
    ws-icon-10 = "10;十";
    ws-icon-default = "%name%";

    format = "<label-state>";

    label-focused = "%icon%";
    label-focused-foreground = colors.base;
    label-focused-background = colors.blue;
    label-focused-padding = 1;
    label-focused-margin = 1;

    label-occupied = "%icon%";
    label-occupied-foreground = colors.text;
    label-occupied-padding = 1;
    label-occupied-margin = 1;

    label-urgent = "%icon%";
    label-urgent-foreground = colors.base;
    label-urgent-background = colors.red;
    label-urgent-padding = 1;
    label-urgent-margin = 1;

    label-empty = "%icon%";
    label-empty-foreground = colors.surface1;
    label-empty-padding = 1;
    label-empty-margin = 1;
  };

  # --- Título da Janela Ativa (Interativo: Clique para Minimizar, Meio para Fechar, Direito para Fullscreen) ---
  "module/xwindow" = {
    type = "internal/xwindow";
    format = "%{A1:${pkgs.bspwm}/bin/bspc node -g hidden=on:}%{A2:${pkgs.bspwm}/bin/bspc node -c:}%{A3:${pkgs.bspwm}/bin/bspc node -t ~fullscreen:}<label>%{A}%{A}%{A}";
    format-prefix = "󰣆 ";
    format-prefix-foreground = colors.sapphire;
    label = "%title:0:30:...%";
    label-foreground = colors.subtext0;
    label-padding = 1;
    label-empty = "Área de Trabalho";
    label-empty-foreground = colors.surface2;
    label-empty-padding = 1;
  };

  # --- Janelas Minimizadas / Ocultas na Polybar (Dinâmica via script) ---
  "module/minimized" = {
    type = "custom/script";
    exec = "${scripts.minimizedScript}";
    interval = 1;
    format = "%{A1:${pkgs.bspwm}/bin/bspc node any.hidden.local -g hidden=off -f:}%{A3:${scripts.restoreMenuScript}:}<label>%{A}%{A}";
    format-background = colors.transparent;
    format-foreground = colors.peach;
    label = "%output%";
    click-left = "${pkgs.bspwm}/bin/bspc node any.hidden.local -g hidden=off -f";
    click-right = "${scripts.restoreMenuScript}";
  };

  # --- Taskbar Interativa de Janelas (Polywins - Ícones e Gestão de Janelas) ---
  "module/polywins" = {
    type = "custom/script";
    exec = "${scripts.polywinsScript}";
    tail = true;
    format = "<label>";
    label = "%output%";
    label-padding = 1;
  };

  # --- Indicador Dinâmico de Layout do BSPWM (bsp-layout) ---
  "module/bsp-layout" = {
    type = "custom/script";
    exec = "${scripts.bspLayoutScript}";
    interval = 1;
    format = "<label>";
    label = "%output%";
    label-padding = 1;
    click-left = "${scripts.rofiLayoutMenu}";
    click-right = "${scripts.bspLayoutSwitchScript} next";
    click-middle = "${scripts.bspLayoutSwitchScript} reset";
    scroll-up = "${scripts.bspLayoutSwitchScript} next";
    scroll-down = "${scripts.bspLayoutSwitchScript} prev";
  };
}
