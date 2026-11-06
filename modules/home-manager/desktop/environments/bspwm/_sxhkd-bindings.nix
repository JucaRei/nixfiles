# modules/home-manager/desktop/environments/bspwm/_sxhkd-bindings.nix
# Agrupamento lógico de atalhos de teclado do BSPWM gerenciados pelo SXHKD.
{
  pkgs,
  mod,
  ctrlMod,
  browserLaunchCmd,
  termCmd,
  fmCmd,
  scripts,
}:
let
  inherit (scripts)
    desktopRightClickScript
    quickSettings
    colorPickerScript
    screenshotScript
    scratchpadScript
    pseudoTileScript
    toggleDesktopScript
    desktopFocusScript
    desktopNodeScript
    resizeScript
    volumeOsd
    brightnessOsd
    mediaControl
    kbdBrightnessOsd
    ;

  # --- Grupo 1: Central de Controle, Preferências e Ferramentas de Tela ---
  controlAndTools = {
    # Clique com botão direito na área de trabalho vazia (Root Window): abre o painel Quick Settings
    "~button3" = "${desktopRightClickScript}";
    # Super + Botão Direito do mouse: abre o painel Quick Settings
    "${mod} + button3" = "${quickSettings}";
    # Super + Vírgula: atalho universal de Preferências e Painel Quick Settings (estilo macOS/GNOME)
    "${mod} + comma" = "${quickSettings}";
    # Super + C: atalho mnemônico para a Central de Controle (Control Center / Quick Settings)
    "${mod} + c" = "${quickSettings}";
    # Super + /: abre o Manual Interativo de Atalhos (Cheat-Sheet via Rofi)
    "${mod} + slash" = "${quickSettings} --manual";
    # Super + F1: Ajuda do sistema e guia de teclas de atalho
    "${mod} + F1" = "${quickSettings} --manual";

    # Super + P: conta-gotas de cor (Colorpicker) - copia código HEX para a área de transferência
    "${mod} + p" = "${colorPickerScript}";
    # Super + Shift + P: menu completo de captura de tela com opções avançadas (ScreenShoTer via Rofi)
    "${mod} + shift + p" = "${screenshotScript} menu";
  };

  # --- Grupo 2: Lançadores de Aplicativos e Scratchpad ---
  apps = {
    # Super + Espaço: menu lançador de aplicativos instalados (Rofi drun)
    "${mod} + space" = "${pkgs.rofi}/bin/rofi -show drun";
    # Super + D: atalho clássico para o lançador de aplicativos (Rofi drun)
    "${mod} + d" = "${pkgs.rofi}/bin/rofi -show drun";
    # Super + Shift + D: executor de comandos de terminal e binários no PATH (Rofi run)
    "${mod} + shift + d" = "${pkgs.rofi}/bin/rofi -show run";

    # Super + B: abre o navegador web padrão (Firefox / LibreWolf)
    "${mod} + b" = browserLaunchCmd;
    # Super + Shift + B: menu interativo de gerenciamento e pareamento Bluetooth (rofi-bluetooth)
    "${mod} + shift + b" = "rofi-bluetooth";

    # Super + Enter: abre o emulador de terminal principal em $HOME
    "${mod} + Return" = termCmd;
    # Super + Enter do Teclado Numérico: abre o emulador de terminal principal
    "${mod} + KP_Enter" = termCmd;
    # Super + T: atalho alternativo para abrir o terminal
    "${mod} + t" = termCmd;

    # Super + E: abre o gerenciador de arquivos padrão (Thunar) em $HOME
    "${mod} + e" = fmCmd;
    # Super + Shift + E: atalho alternativo para o gerenciador de arquivos
    "${mod} + shift + e" = fmCmd;

    # Super + W: alternador visual de janelas ativas em todos os workspaces (Rofi window)
    "${mod} + w" = "${pkgs.rofi}/bin/rofi -show window";

    # Super + U: abre ou oculta o terminal suspenso flutuante rápido (Scratchpad drop-down)
    "${mod} + u" = "${scratchpadScript}";
  };

  # --- Grupo 3: Gerenciamento, Estados, Camadas e Bloqueio de Janelas ---
  windows = {
    # Fechamento e Encerramento
    "${mod} + q" = "bspc node -c";
    "${mod} + shift + q" = "bspc node -k";
    "${mod} + shift + Escape" = "bspc node -k";

    # Estados de Janela (Flutuante / Tela Cheia / Pseudo-Tiled / Monocle)
    "${mod} + f" = "bspc node -t '~floating'";
    "${mod} + s" = "bspc node -t '~floating'";
    "${mod} + a" = "bspc node -t '~fullscreen'";
    "${mod} + shift + f" = "${pseudoTileScript}";
    "${mod} + shift + t" = "${pseudoTileScript}";
    "${mod} + m" = "bspc desktop -l next";

    # Camadas e Sobreposição (PIP / Sempre no topo)
    "${mod} + equal" = "bspc node focused -l above";
    "${mod} + plus" = "bspc node focused -l above";
    "${mod} + underscore" = "bspc node focused -l normal";

    # Minimizar / Esconder Janelas e Mostrar Área de Trabalho
    "${mod} + y" = "bspc node -g hidden=on";
    "${mod} + minus" = "bspc node -g hidden=on";
    "${mod} + shift + y" = "bspc node any.hidden.local -g hidden=off -f";
    "${mod} + shift + minus" = "bspc node any.hidden.local -g hidden=off -f";
    "${mod} + shift + m" = "${toggleDesktopScript}";

    # Bloqueio de Sessão e Segurança
    "${mod} + ${ctrlMod} + q" = "bspwm-lock || loginctl lock-session";
    "${mod} + shift + x" = "bspwm-lock || loginctl lock-session";
    "${mod} + shift + l" = "bspwm-lock || loginctl lock-session";
    "XF86ScreenSaver" = "bspwm-lock || loginctl lock-session";
  };

  # --- Grupo 4: Navegação, Foco e Árvore BSP ---
  navigation = {
    # Foco direcional (Vim e Setas)
    "${mod} + {h,j,k,l}" = "bspc node -f {west,south,north,east}";
    "${mod} + {Left,Down,Up,Right}" = "bspc node -f {west,south,north,east}";
    "${mod} + shift + {h,j,k,l}" = "bspc node -s {west,south,north,east}";
    "${mod} + shift + {Left,Down,Up,Right}" = "bspc node -s {west,south,north,east}";

    # Ciclar foco
    "${mod} + Tab" = "bspc node -f next.local.!hidden.window || bspc node -f next.local.window";
    "${mod} + shift + Tab" = "bspc node -f prev.local.!hidden.window || bspc node -f prev.local.window";
    "${mod} + grave" = "bspc node -f next.local.!hidden.window || bspc node -f next.local.window";
    "${mod} + shift + grave" =
      "bspc node -f prev.local.!hidden.window || bspc node -f prev.local.window";
    "${mod} + backslash" = "bspc node -f last.local.!hidden.window";

    # Troca de posição
    "${mod} + ctrl + Tab" = "bspc node -s next.local.!hidden.window";
    "${mod} + ctrl + shift + Tab" = "bspc node -s prev.local.!hidden.window";
    "${mod} + ctrl + grave" = "bspc node -s next.local.!hidden.window";
    "${mod} + ctrl + shift + grave" = "bspc node -s prev.local.!hidden.window";

    # Árvore BSP (Pai e Irmão)
    "${mod} + ctrl + p" = "bspc node -f @parent";
    "${mod} + ctrl + b" = "bspc node -f @brother";
    "${mod} + ctrl + shift + p" = "bspc node -s @parent";
    "${mod} + ctrl + shift + b" = "bspc node -s @brother";
  };

  # --- Grupo 5: Gerenciamento Dinâmico de Layouts (bsp-layout) ---
  layouts = {
    "${mod} + ctrl + space" = "bsp-layout-switch next";
    "${mod} + ctrl + shift + space" = "bsp-layout-switch prev";
    "${mod} + ctrl + l" = "rofi-bsp-layout";
    "${mod} + ctrl + t" = "bsp-layout-switch tall";
    "${mod} + ctrl + c" = "bsp-layout-switch columns";
    "${mod} + ctrl + z" = "bsp-layout zoom";
    "${mod} + ctrl + w" = "bsp-layout-switch wide";
    "${mod} + ctrl + g" = "bsp-layout-switch grid";
    "${mod} + ctrl + e" = "bsp-layout-switch even";
    "${mod} + ctrl + m" = "bsp-layout-switch monocle";
    "${mod} + ctrl + r" = "bsp-layout-switch reset";
  };

  # --- Grupo 6: Multi-Monitores e Áreas de Trabalho (Workspaces) ---
  workspaces = {
    "${mod} + bracketleft" = "bspc monitor -f prev";
    "${mod} + bracketright" = "bspc monitor -f next";
    "${mod} + shift + bracketleft" = "bspc node -m prev --follow";
    "${mod} + shift + bracketright" = "bspc node -m next --follow";

    "${mod} + {1-9,0}" = "${desktopFocusScript} {1-9,0}";
    "${mod} + shift + {1-9,0}" = "${desktopNodeScript} {1-9,0} true";
    "${mod} + ctrl + {1-9,0}" = "${desktopNodeScript} {1-9,0} false";
  };

  # --- Grupo 7: Redimensionamento e Reinicialização ---
  resizeAndRestart = {
    "${mod} + ctrl + {Left,Down,Up,Right}" = "${resizeScript} {left,down,up,right}";
    "${mod} + ctrl + {h,j,k,l}" = "${resizeScript} {left,down,up,right}";
    "${mod} + ctrl + shift + {h,j,k,l}" = "${resizeScript} {left,down,up,right}";

    "${mod} + shift + r" = "bspc wm -r; ${pkgs.procps}/bin/pkill -USR1 -x sxhkd; polybar-launch &";
    "${mod} + Escape" = "${pkgs.procps}/bin/pkill -USR1 -x sxhkd";
  };

  # --- Grupo 8: Controles de Mídia, Volume e Brilho (com OSD Dunst) ---
  mediaAndBrightness = {
    "XF86AudioRaiseVolume" = "${volumeOsd} up";
    "XF86AudioLowerVolume" = "${volumeOsd} down";
    "XF86AudioMute" = "${volumeOsd} mute";
    "XF86AudioPlay" = "${mediaControl} play-pause";
    "XF86AudioNext" = "${mediaControl} next";
    "XF86AudioPrev" = "${mediaControl} prev";
    "XF86AudioStop" = "${mediaControl} stop";

    "XF86MonBrightnessUp" = "${brightnessOsd} up";
    "XF86MonBrightnessDown" = "${brightnessOsd} down";

    "XF86KbdBrightnessUp" = "${kbdBrightnessOsd} up";
    "XF86KbdBrightnessDown" = "${kbdBrightnessOsd} down";
    "XF86KbdLightOnOff" = "${kbdBrightnessOsd} toggle";

    "${mod} + F6" = "${kbdBrightnessOsd} up";
    "${mod} + F5" = "${kbdBrightnessOsd} down";
    "${mod} + shift + F5" = "${kbdBrightnessOsd} toggle";

    "${mod} + F4" = "${kbdBrightnessOsd} up";
    "${mod} + F3" = "${kbdBrightnessOsd} down";
    "${mod} + shift + F4" = "${kbdBrightnessOsd} toggle";
  };
in
controlAndTools
// apps
// windows
// navigation
// layouts
// workspaces
// resizeAndRestart
// mediaAndBrightness
