# Declarative MangoWM keybindings and mousebindings.
{
  config,
  pkgs,
  mod,
  altMod,
  ctrlMod,
  isNoctalia,
  isApple,
  screenshotFull,
  screenshotArea,
  screenshotPick,
  cliphistMenu,
  kbdBrightnessOsd,
  monBrightnessOsd,
}:
''
  # ============================================================================
  # Atalhos de Teclado (Keybindings)
  # ============================================================================

  # Recarregar Configurações (MangoWM + Noctalia / Waybar)
  bind=${mod},r,spawn,mango-reload
  bind=${mod}+SHIFT,r,spawn,mango-reload --restart
  bind=${mod}+${altMod},r,spawn,mango-reload

  # Aplicativos e Utilitários
  bind=${mod},Return,spawn,${config.system.programs.terminal.activeCommand or "terminal"}
  bind=${mod}+${ctrlMod},Return,spawn,${
    config.system.programs.terminal.scratchpadCommand or "terminal"
  }
  ${
    if isNoctalia then
      ''
        bind=${mod},space,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle launcher
        bind=${mod},d,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle launcher
        bind=${mod},v,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle clipboard
        bind=${mod},p,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle control-center
        bind=${mod},s,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle control-center
        bind=${mod},Escape,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle session
        bind=${mod}+SHIFT,e,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle session
        bind=${mod},comma,spawn,${pkgs.noctalia}/bin/noctalia msg settings-toggle
        bind=${mod}+${altMod},w,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle wallpaper

        # Window Switcher (Alt+Tab Overlay nativo do Noctalia)
        bindc=${altMod},Tab,spawn,${pkgs.noctalia}/bin/noctalia msg window-switcher
        bindc=${altMod}+SHIFT,Tab,spawn,${pkgs.noctalia}/bin/noctalia msg window-switcher

        # Sessão: Lock e Suspend
        bind=${mod}+${altMod},l,spawn,${pkgs.noctalia}/bin/noctalia msg session lock
        ${
          if isApple then
            ''
              bind=${mod}+${ctrlMod},q,spawn,${pkgs.noctalia}/bin/noctalia msg session lock
            ''
          else
            ""
        }
        bind=${mod}+${altMod},s,spawn,${pkgs.noctalia}/bin/noctalia msg session suspend
        bind=NONE,XF86Sleep,spawn,${pkgs.noctalia}/bin/noctalia msg session suspend

        # Night Light e Caffeine
        bind=${mod}+SHIFT,n,spawn,${pkgs.noctalia}/bin/noctalia msg nightlight-toggle
        bind=${mod}+${ctrlMod}+SHIFT,n,spawn,${pkgs.noctalia}/bin/noctalia msg nightlight-force-toggle
        bind=${mod}+SHIFT,c,spawn,${pkgs.noctalia}/bin/noctalia msg caffeine-toggle
      ''
    else
      ''
        bind=${mod},space,spawn,${pkgs.rofi}/bin/rofi -show drun
        bind=${mod},d,spawn,${pkgs.rofi}/bin/rofi -show drun
        bind=${mod},v,spawn,${cliphistMenu}
        bind=${mod},Escape,spawn,session-power-menu
        bind=${mod}+SHIFT,e,spawn,session-power-menu
        bind=${mod}+${altMod},l,spawn,${pkgs.hyprlock}/bin/hyprlock
        ${
          if isApple then
            ''
              bind=${mod}+${ctrlMod},q,spawn,${pkgs.hyprlock}/bin/hyprlock
            ''
          else
            ""
        }
        bind=${mod}+${altMod},s,spawn,systemctl suspend
        bind=NONE,XF86Sleep,spawn,systemctl suspend
        bindc=${altMod},Tab,toggleoverview,
      ''
  }
  bind=${mod},e,spawn,${config.system.programs.file-manager.activeCommand or "file-manager"}
  bind=${mod}+SHIFT,q,quit

  # Ajuda e Lista de Atalhos de Teclado (Plugin Keymap)
  ${
    if isNoctalia then
      ''
        bind=${mod},F1,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle blackbartblues/keymap:panel
        bind=${mod},slash,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle blackbartblues/keymap:panel
        bind=${mod}+SHIFT,question,spawn,${pkgs.noctalia}/bin/noctalia msg panel-toggle blackbartblues/keymap:panel
      ''
    else
      ""
  }

  # Gerenciamento de Janelas e Estados
  bind=${mod},q,killclient,
  bind=${mod},f,togglefloating,
  bind=${mod},backslash,togglefloating,
  ${
    if isNoctalia then
      ''
        # Alt+Tab overlay gerenciado via Noctalia
      ''
    else
      ''
        bind=${altMod},Tab,toggleoverview,
      ''
  }
  bind=${mod},Tab,focusstack,next
  bind=ALT,a,togglefullscreen,
  bind=${mod},i,minimized,
  bind=${mod}+SHIFT,i,restore_minimized
  bind=${mod}+SHIFT,o,toggleoverlay,
  bind=${mod}+SHIFT,g,toggleglobal,
  bind=${altMod},z,toggle_scratchpad

  # Redimensionamento de Janelas
  bind=${mod},equal,resizewin,20,0
  bind=${mod},minus,resizewin,-20,0
  bind=${mod}+${ctrlMod},equal,resizewin,0,20
  bind=${mod}+${ctrlMod},minus,resizewin,0,-20

  # Layouts e Proporções
  bind=${ctrlMod},space,switch_layout
  bind=${mod},n,switch_layout
  bind=${ctrlMod}+SHIFT,space,spawn,mango-layout-picker
  bind=${mod}+${altMod},space,spawn,mango-layout-picker
  bind=${mod}+${altMod},f,set_proportion,1.0
  bind=${altMod},space,switch_proportion_preset,
  bind=${mod}+${altMod},c,scroller_stack,left
  bind=${mod}+${altMod}+SHIFT,c,scroller_stack,right

  # Ajustes de Gaps
  bind=${altMod}+SHIFT,x,incgaps,2
  bind=${altMod}+SHIFT,z,incgaps,-2
  bind=${altMod}+SHIFT,r,togglegaps
  bind=${mod}+SHIFT,a,spawn,mango-toggle-outer-gaps

  # Foco Direcional (Setas e Vim Keys)
  bind=${mod},Left,focusdir,left
  bind=${mod},Right,focusdir,right
  bind=${mod},Up,focusdir,up
  bind=${mod},Down,focusdir,down
  bind=${mod},h,focusdir,left
  bind=${mod},l,focusdir,right
  bind=${mod},k,focusdir,up
  bind=${mod},j,focusdir,down

  # Trocar Janelas de Posição (Setas e Vim Keys)
  bind=${mod}+SHIFT,Left,exchange_client,left
  bind=${mod}+SHIFT,Right,exchange_client,right
  bind=${mod}+SHIFT,Up,exchange_client,up
  bind=${mod}+SHIFT,Down,exchange_client,down
  bind=${mod}+SHIFT,h,exchange_client,left
  bind=${mod}+SHIFT,l,exchange_client,right
  bind=${mod}+SHIFT,k,exchange_client,up
  bind=${mod}+SHIFT,j,exchange_client,down

  # Controle de Tags (1 a 9)
  bind=${mod},1,view,1
  bind=${mod},2,view,2
  bind=${mod},3,view,3
  bind=${mod},4,view,4
  bind=${mod},5,view,5
  bind=${mod},6,view,6
  bind=${mod},7,view,7
  bind=${mod},8,view,8
  bind=${mod},9,view,9

  # Mover Janelas para Tags (1 a 9)
  bind=${mod}+${ctrlMod},1,tag,1,0
  bind=${mod}+${ctrlMod},2,tag,2,0
  bind=${mod}+${ctrlMod},3,tag,3,0
  bind=${mod}+${ctrlMod},4,tag,4,0
  bind=${mod}+${ctrlMod},5,tag,5,0
  bind=${mod}+${ctrlMod},6,tag,6,0
  bind=${mod}+${ctrlMod},7,tag,7,0
  bind=${mod}+${ctrlMod},8,tag,8,0
  bind=${mod}+${ctrlMod},9,tag,9,0

  bind=${mod}+SHIFT,1,tag,1,0
  bind=${mod}+SHIFT,2,tag,2,0
  ${
    if isApple then
      ''
        # No hardware Apple, SUPER+SHIFT+3, 4, 5 são atalhos de Captura de Tela estilo macOS (Cmd+Shift+3/4/5)
        # O envio de janelas para as tags 3, 4 e 5 é feito via SUPER+CTRL+3, 4, 5
      ''
    else
      ''
        bind=${mod}+SHIFT,3,tag,3,0
        bind=${mod}+SHIFT,4,tag,4,0
        bind=${mod}+SHIFT,5,tag,5,0
      ''
  }
  bind=${mod}+SHIFT,6,tag,6,0
  bind=${mod}+SHIFT,7,tag,7,0
  bind=${mod}+SHIFT,8,tag,8,0
  bind=${mod}+SHIFT,9,tag,9,0

  # Navegação entre Tags Adjacentes
  bind=${mod}+${ctrlMod},Up,viewtoleft,0
  bind=${mod}+${ctrlMod},Down,viewtoright,0
  bind=${mod}+${ctrlMod}+${altMod},Up,tagtoleft,0
  bind=${mod}+${ctrlMod}+${altMod},Down,tagtoright,0

  # Teclas Multimídia e Áudio
  ${
    if isNoctalia then
      ''
        bind=NONE,XF86AudioRaiseVolume,spawn,${pkgs.noctalia}/bin/noctalia msg volume-up
        bind=NONE,XF86AudioLowerVolume,spawn,${pkgs.noctalia}/bin/noctalia msg volume-down
        bind=NONE,XF86AudioMute,spawn,${pkgs.noctalia}/bin/noctalia msg volume-mute
        bind=NONE,XF86AudioMicMute,spawn,${pkgs.noctalia}/bin/noctalia msg mic-mute
        bind=NONE,XF86AudioPlay,spawn,${pkgs.noctalia}/bin/noctalia msg media toggle
        bind=NONE,XF86AudioNext,spawn,${pkgs.noctalia}/bin/noctalia msg media next
        bind=NONE,XF86AudioPrev,spawn,${pkgs.noctalia}/bin/noctalia msg media previous

        # Brilho da Tela (Feedback OSD Nativo do Noctalia)
        bind=NONE,XF86MonBrightnessUp,spawn,${pkgs.noctalia}/bin/noctalia msg brightness-up
        bind=NONE,XF86MonBrightnessDown,spawn,${pkgs.noctalia}/bin/noctalia msg brightness-down

        # Iluminação do Teclado (Feedback OSD Nativo do Noctalia)
        bind=NONE,XF86KbdBrightnessUp,spawn,${pkgs.noctalia}/bin/noctalia msg keyboard-backlight-up
        bind=NONE,XF86KbdBrightnessDown,spawn,${pkgs.noctalia}/bin/noctalia msg keyboard-backlight-down
        bind=NONE,XF86KbdLightOnOff,spawn,${pkgs.noctalia}/bin/noctalia msg keyboard-backlight-toggle
        bind=${mod},F6,spawn,${pkgs.noctalia}/bin/noctalia msg keyboard-backlight-up
        bind=${mod},F5,spawn,${pkgs.noctalia}/bin/noctalia msg keyboard-backlight-down
        bind=${mod}+SHIFT,F5,spawn,${pkgs.noctalia}/bin/noctalia msg keyboard-backlight-toggle

        # Captura de Tela (Screenshots via Noctalia IPC)
        ${
          if isApple then
            ''
              # Mapeamento oficial Apple macOS: Cmd+Shift+3 (Tela inteira), Cmd+Shift+4 (Região), Cmd+Shift+5 (Menu/Seleção)
              bind=${mod}+SHIFT,3,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-fullscreen
              bind=${mod}+SHIFT,4,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-region
              bind=${mod}+SHIFT,5,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-fullscreen pick
              bind=NONE,Print,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-fullscreen
              bind=SHIFT,Print,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-region
              bind=${mod}+SHIFT,S,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-region
            ''
          else
            ''
              # Padrão PC
              bind=NONE,Print,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-fullscreen
              bind=SHIFT,Print,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-region
              bind=${mod}+SHIFT,S,spawn,${pkgs.noctalia}/bin/noctalia msg screenshot-region
            ''
        }
      ''
    else
      ''
        bind=NONE,XF86AudioRaiseVolume,spawn,${pkgs.pamixer}/bin/pamixer --allow-boost --set-limit 150 -i 5
        bind=NONE,XF86AudioLowerVolume,spawn,${pkgs.pamixer}/bin/pamixer -d 5
        bind=NONE,XF86AudioMute,spawn,${pkgs.pamixer}/bin/pamixer -t
        bind=NONE,XF86AudioMicMute,spawn,${pkgs.pamixer}/bin/pamixer --default-source -t
        bind=NONE,XF86AudioPlay,spawn,${pkgs.playerctl}/bin/playerctl play-pause
        bind=NONE,XF86AudioNext,spawn,${pkgs.playerctl}/bin/playerctl next
        bind=NONE,XF86AudioPrev,spawn,${pkgs.playerctl}/bin/playerctl previous

        # Brilho da Tela (com Feedback OSD)
        bind=NONE,XF86MonBrightnessUp,spawn,${monBrightnessOsd} up
        bind=NONE,XF86MonBrightnessDown,spawn,${monBrightnessOsd} down

        # Iluminação do Teclado (MacBook F5/F6 e Logitech MX Keys F3/F4)
        bind=NONE,XF86KbdBrightnessUp,spawn,${kbdBrightnessOsd} up
        bind=NONE,XF86KbdBrightnessDown,spawn,${kbdBrightnessOsd} down
        bind=NONE,XF86KbdLightOnOff,spawn,${kbdBrightnessOsd} toggle
        bind=${mod},F6,spawn,${kbdBrightnessOsd} up
        bind=${mod},F5,spawn,${kbdBrightnessOsd} down
        bind=${mod}+SHIFT,F5,spawn,${kbdBrightnessOsd} toggle
        bind=${mod},F4,spawn,${kbdBrightnessOsd} up
        bind=${mod},F3,spawn,${kbdBrightnessOsd} down
        bind=${mod}+SHIFT,F4,spawn,${kbdBrightnessOsd} toggle
        bind=${mod}+SHIFT,F3,spawn,${kbdBrightnessOsd} toggle

        # Captura de Tela (Screenshots)
        ${
          if isApple then
            ''
              # Mapeamento oficial Apple macOS: Cmd+Shift+3 (Tela inteira), Cmd+Shift+4 (Região), Cmd+Shift+5 (Menu/Seleção)
              bind=${mod}+SHIFT,3,spawn,${screenshotFull}
              bind=${mod}+SHIFT,4,spawn,${screenshotArea}
              bind=${mod}+SHIFT,5,spawn,${screenshotPick}
              bind=NONE,Print,spawn,${screenshotFull}
              bind=SHIFT,Print,spawn,${screenshotArea}
              bind=${mod}+SHIFT,S,spawn,${screenshotArea}
            ''
          else
            ''
              # Padrão PC
              bind=NONE,Print,spawn,${screenshotFull}
              bind=SHIFT,Print,spawn,${screenshotArea}
              bind=${mod}+SHIFT,S,spawn,${screenshotArea}
            ''
        }
      ''
  }

  # Mouse
  mousebind=${mod},btn_left,moveresize,curmove
  mousebind=${mod},btn_right,moveresize,curresize
  mousebind=NONE,btn_middle,togglemaximizescreen,0
''
