# Declarative Hyprland keybindings and mousebindings.
{
  pkgs,
  config,
  isNoctalia,
  isApple,
  altMod,
  ctrlMod,
  screenshotFull,
  screenshotArea,
  screenshotPick,
  kbdBrightnessOsd,
  monBrightnessOsd,
}:
{
  bind = [
    # Aplicações e Launcher
    "$mainMod, RETURN, exec, ${config.system.programs.terminal.activeCommand or "terminal"}"
    (
      if isNoctalia then
        "$mainMod, SPACE, exec, noctalia-launcher"
      else
        "$mainMod, SPACE, exec, ${pkgs.rofi}/bin/rofi -show drun"
    )
    (
      if isNoctalia then
        "$mainMod, D, exec, noctalia-launcher"
      else
        "$mainMod, D, exec, ${pkgs.rofi}/bin/rofi -show drun"
    )
    (if isNoctalia then "$mainMod, V, exec, noctalia-cliphist" else "$mainMod, V, exec, hypr-cliphist")
    (if isNoctalia then "$mainMod, P, exec, noctalia-control-center" else "$mainMod, P, pseudo,")
    (
      if isNoctalia then
        "$mainMod, Escape, exec, noctalia-session-menu"
      else
        "$mainMod, Escape, exec, session-power-menu"
    )
    "$mainMod, E, exec, ${config.system.programs.file-manager.activeCommand or "file-manager"}"
    (
      if isNoctalia then
        "$mainMod, L, exec, ${pkgs.noctalia}/bin/noctalia msg session lock"
      else
        "$mainMod, L, exec, ${pkgs.hyprlock}/bin/hyprlock"
    )
    (
      if isNoctalia then
        "$mainMod ${altMod}, S, exec, ${pkgs.noctalia}/bin/noctalia msg session suspend"
      else
        "$mainMod ${altMod}, S, exec, systemctl suspend"
    )

    # Recarregar Configurações (Hyprland + Noctalia / Waybar)
    "$mainMod, R, exec, ${pkgs.hyprland}/bin/hyprctl reload && (noctalia msg config-reload 2>/dev/null || pkill -SIGUSR2 waybar 2>/dev/null || true) && ${pkgs.libnotify}/bin/notify-send -u low -i 'preferences-desktop' 'Hyprland' 'Configurações recarregadas com sucesso!'"
    "$mainMod SHIFT, R, exec, ${pkgs.hyprland}/bin/hyprctl reload && (systemctl --user restart noctalia 2>/dev/null || systemctl --user restart waybar 2>/dev/null || true) && ${pkgs.libnotify}/bin/notify-send -u low -i 'preferences-desktop' 'Hyprland' 'Configurações recarregadas e Shell reiniciado!'"

    # Gerenciamento de Janelas
    "$mainMod, Q, killactive,"
    "$mainMod, C, killactive,"
    "$mainMod, F, togglefloating,"
    "$mainMod, S, togglefloating,"
    "ALT, A, fullscreen, 0"
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

    # Mover Janela para Workspace (via ctrlMod para compatibilidade com Apple)
    "$mainMod ${ctrlMod}, 1, movetoworkspace, 1"
    "$mainMod ${ctrlMod}, 2, movetoworkspace, 2"
    "$mainMod ${ctrlMod}, 3, movetoworkspace, 3"
    "$mainMod ${ctrlMod}, 4, movetoworkspace, 4"
    "$mainMod ${ctrlMod}, 5, movetoworkspace, 5"
    "$mainMod ${ctrlMod}, 6, movetoworkspace, 6"
    "$mainMod ${ctrlMod}, 7, movetoworkspace, 7"
    "$mainMod ${ctrlMod}, 8, movetoworkspace, 8"
    "$mainMod ${ctrlMod}, 9, movetoworkspace, 9"
    "$mainMod ${ctrlMod}, 0, movetoworkspace, 10"

    # Mover Janela para Workspace (1 a 10)
    "$mainMod SHIFT, 1, movetoworkspace, 1"
    "$mainMod SHIFT, 2, movetoworkspace, 2"
  ]
  ++ (
    if isApple then
      [ ]
    else
      [
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
      ]
  )
  ++ [
    "$mainMod SHIFT, 6, movetoworkspace, 6"
    "$mainMod SHIFT, 7, movetoworkspace, 7"
    "$mainMod SHIFT, 8, movetoworkspace, 8"
    "$mainMod SHIFT, 9, movetoworkspace, 9"
    "$mainMod SHIFT, 0, movetoworkspace, 10"
  ]
  ++ (
    if isNoctalia then
      [
        # Window Switcher (Alt+Tab Overlay)
        "${altMod}, TAB, exec, ${pkgs.noctalia}/bin/noctalia msg window-switcher"
        "${altMod} SHIFT, TAB, exec, ${pkgs.noctalia}/bin/noctalia msg window-switcher"

        # Night Light e Caffeine
        "$mainMod SHIFT, N, exec, ${pkgs.noctalia}/bin/noctalia msg nightlight-toggle"
        "$mainMod ${ctrlMod} SHIFT, N, exec, ${pkgs.noctalia}/bin/noctalia msg nightlight-force-toggle"
        "$mainMod SHIFT, C, exec, ${pkgs.noctalia}/bin/noctalia msg caffeine-toggle"
      ]
    else
      [ ]
  )
  ++ (
    if isApple then
      [
        # Bloqueio de Tela estilo macOS (Ctrl+Cmd+Q)
        "$mainMod CTRL, Q, exec, ${
          if isNoctalia then
            "${pkgs.noctalia}/bin/noctalia msg session lock"
          else
            "${pkgs.hyprlock}/bin/hyprlock"
        }"
      ]
    else
      [ ]
  )
  ++ (
    if isNoctalia then
      (
        if isApple then
          [
            # Captura de Tela estilo Apple macOS (Cmd+Shift+3, Cmd+Shift+4, Cmd+Shift+5)
            "$mainMod SHIFT, 3, exec, ${pkgs.noctalia}/bin/noctalia msg screenshot-fullscreen"
            "$mainMod SHIFT, 4, exec, ${pkgs.noctalia}/bin/noctalia msg screenshot-region"
            "$mainMod SHIFT, 5, exec, ${pkgs.noctalia}/bin/noctalia msg screenshot-fullscreen pick"
            ", Print, exec, ${pkgs.noctalia}/bin/noctalia msg screenshot-fullscreen"
            "SHIFT, Print, exec, ${pkgs.noctalia}/bin/noctalia msg screenshot-region"
            "$mainMod SHIFT, S, exec, ${pkgs.noctalia}/bin/noctalia msg screenshot-region"
          ]
        else
          [
            # Captura de Tela Padrão PC
            ", Print, exec, ${pkgs.noctalia}/bin/noctalia msg screenshot-fullscreen"
            "SHIFT, Print, exec, ${pkgs.noctalia}/bin/noctalia msg screenshot-region"
            "$mainMod SHIFT, S, exec, ${pkgs.noctalia}/bin/noctalia msg screenshot-region"
          ]
      )
    else
      (
        if isApple then
          [
            # Captura de Tela estilo Apple macOS (Cmd+Shift+3, Cmd+Shift+4, Cmd+Shift+5)
            "$mainMod SHIFT, 3, exec, ${screenshotFull}"
            "$mainMod SHIFT, 4, exec, ${screenshotArea}"
            "$mainMod SHIFT, 5, exec, ${screenshotPick}"
            ", Print, exec, ${screenshotFull}"
            "SHIFT, Print, exec, ${screenshotArea}"
            "$mainMod SHIFT, S, exec, ${screenshotArea}"
          ]
        else
          [
            # Captura de Tela Padrão PC
            ", Print, exec, ${screenshotFull}"
            "SHIFT, Print, exec, ${screenshotArea}"
            "$mainMod SHIFT, S, exec, ${screenshotArea}"
          ]
      )
  )
  ++ [
    # Menu de Energia / Logout
    "$mainMod, ESCAPE, exec, ${if isNoctalia then "noctalia-session-menu" else "hyprland-power-menu"}"
    "$mainMod SHIFT, E, exec, ${if isNoctalia then "noctalia-session-menu" else "hyprland-power-menu"}"
  ];

  bindl = [
    # Teclas de Mídia e Áudio
    ", XF86AudioMute, exec, ${pkgs.pamixer}/bin/pamixer -t"
    ", XF86AudioMicMute, exec, ${pkgs.pamixer}/bin/pamixer --default-source -t"
    ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
    ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
    ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"

    # Suspensão do Sistema (Sleep Key)
    ", XF86Sleep, exec, ${
      if isNoctalia then "${pkgs.noctalia}/bin/noctalia msg session suspend" else "systemctl suspend"
    }"

    # Iluminação do Teclado (Liga/Desliga)
    ", XF86KbdLightOnOff, exec, ${kbdBrightnessOsd} toggle"
    "$mainMod SHIFT, F5, exec, ${kbdBrightnessOsd} toggle"
    "$mainMod SHIFT, F4, exec, ${kbdBrightnessOsd} toggle"
    "$mainMod SHIFT, F3, exec, ${kbdBrightnessOsd} toggle"
  ];

  binde = [
    # Volume e Brilho com repetição contínua
    ", XF86AudioRaiseVolume, exec, ${pkgs.pamixer}/bin/pamixer --allow-boost --set-limit 150 -i 5"
    ", XF86AudioLowerVolume, exec, ${pkgs.pamixer}/bin/pamixer -d 5"
    ", XF86MonBrightnessUp, exec, ${monBrightnessOsd} up"
    ", XF86MonBrightnessDown, exec, ${monBrightnessOsd} down"

    # Iluminação do Teclado (MacBook F5/F6 e Logitech MX Keys F3/F4)
    ", XF86KbdBrightnessUp, exec, ${kbdBrightnessOsd} up"
    ", XF86KbdBrightnessDown, exec, ${kbdBrightnessOsd} down"
    "$mainMod, F6, exec, ${kbdBrightnessOsd} up"
    "$mainMod, F5, exec, ${kbdBrightnessOsd} down"
    "$mainMod, F4, exec, ${kbdBrightnessOsd} up"
    "$mainMod, F3, exec, ${kbdBrightnessOsd} down"
  ];

  bindm = [
    "$mainMod, mouse:272, movewindow"
    "$mainMod, mouse:273, resizewindow"
  ];

}
