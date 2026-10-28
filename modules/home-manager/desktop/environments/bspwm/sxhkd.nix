{
  config,
  lib,
  pkgs,
  nixGLWrapper ? lib.id,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) attrsOf bool str;
  cfg = config.desktop.bspwm.sxhkd;
  fmCmd = config.system.programs.file-manager.activeCommand or "file-manager";

  terminalCfg = config.system.programs.terminal;
  termCmd = terminalCfg.activeCommand;
  termDisplayName = terminalCfg.activeName;
  scratchpadLaunchCmd = "${terminalCfg.scratchpadCommand} &";

  browserBin = config.system.programs.browsers.activeBin or null;
  browserLaunchCmd =
    if browserBin != null then
      "${browserBin} &"
    else
      ''if [ -n "$BROWSER" ]; then "$BROWSER" & else ${pkgs.xdg-utils}/bin/xdg-open https:// 2>/dev/null || firefox 2>/dev/null || x-www-browser & fi'';

  picomBin = "${nixGLWrapper pkgs.picom}/bin/picom";

  screenshotSavePath = "${config.home.homeDirectory}/Pictures/Screenshots";

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

  mod =
    if normMod == "Alt" then
      "alt"
    else if normMod == "Ctrl" then
      "ctrl"
    else
      "super";

  ctrlMod = if mod == "ctrl" then "super" else "ctrl";
  modDisplayName = normMod;

  writeShellApp =
    args:
    pkgs.writeShellApplication (
      args
      // {
        bashOptions = args.bashOptions or [ ];
        excludeShellChecks = (args.excludeShellChecks or [ ]) ++ [
          "SC1091"
          "SC2001"
          "SC2005"
          "SC2012"
          "SC2015"
          "SC2016"
          "SC2028"
          "SC2034"
          "SC2046"
          "SC2059"
          "SC2076"
          "SC2086"
          "SC2089"
          "SC2090"
          "SC2119"
          "SC2120"
          "SC2126"
          "SC2154"
          "SC2155"
          "SC2181"
          "SC2183"
          "SC2206"
          "SC2207"
          "SC2221"
          "SC2222"
        ];
      }
    );

  scratchpadScriptPkg = writeShellApp {
    name = "bspwm-scratchpad";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.jq
      pkgs.xdo
      pkgs.xprop
    ];
    runtimeEnv = {
      SCRATCHPAD_LAUNCH_CMD = scratchpadLaunchCmd;
    };
    text = builtins.readFile ./scripts/bspwm-scratchpad.sh;
  };
  scratchpadScript = lib.getExe scratchpadScriptPkg;

  resizeScriptPkg = writeShellApp {
    name = "bspwm-resize";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.coreutils
    ];
    text = builtins.readFile ./scripts/bspwm-resize.sh;
  };
  resizeScript = lib.getExe resizeScriptPkg;

  screenshotScriptPkg = writeShellApp {
    name = "bspwm-screenshot";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.byzanz
      pkgs.dunst
      pkgs.feh
      pkgs.ffmpeg
      pkgs.jq
      pkgs.maim
      (nixGLWrapper pkgs.picom)
      pkgs.procps
      pkgs.rofi
      pkgs.slop
      pkgs.xclip
      pkgs.xdg-utils
    ];
    runtimeEnv = {
      FILE_MANAGER_CMD = fmCmd;
      PICOM_BIN = picomBin;
      SCREENSHOT_SAVE_PATH = screenshotSavePath;
    };
    text = builtins.readFile ./scripts/bspwm-screenshot.sh;
  };
  screenshotScript = lib.getExe screenshotScriptPkg;

  isAppleKeyboard =
    (config.home.keyboard.model or "") == "apple" || (config.home.keyboard.model or "") == "macbook";

  effectiveScreenshotProfile =
    if cfg.screenshotProfile != "auto" then
      cfg.screenshotProfile
    else if isAppleKeyboard then
      "mac"
    else
      "standard";

  screenshotBindings =
    if effectiveScreenshotProfile == "none" then
      { }
    else if effectiveScreenshotProfile == "custom" then
      cfg.screenshotKeybindings
    else if effectiveScreenshotProfile == "mac" then
      {
        # --- Perfil macOS (MacBook Pro / Air e teclados Apple sem tecla Print física) ---
        "${mod} + shift + 3" = "${screenshotScript} full";
        "${mod} + shift + 4" = "${screenshotScript} area";
        "${mod} + shift + 5" = "${screenshotScript} menu";
        "${mod} + shift + 6" = "${screenshotScript} gif";
        "Print" = "${screenshotScript} full";
        "shift + Print" = "${screenshotScript} area";
        "ctrl + Print" = "${screenshotScript} window";
        "ctrl + shift + Print" = "${screenshotScript} gif";
        "super + shift + s" = "${screenshotScript} menu";
        "${mod} + ctrl + shift + s" = "${screenshotScript} gif";
        "XF86SelectiveScreenshot" = "${screenshotScript} area";
      }
      // lib.optionalAttrs (mod != "super") {
        "${mod} + shift + s" = "${screenshotScript} area";
      }
    else
      {
        # --- Perfil Standard / PC (Acer Nitro, PCs desktop, VMs, etc.) ---
        "Print" = "${screenshotScript} full";
        "shift + Print" = "${screenshotScript} area";
        "ctrl + Print" = "${screenshotScript} window";
        "ctrl + shift + Print" = "${screenshotScript} gif";
        "${mod} + shift + Print" = "${screenshotScript} in5";
        "${mod} + Print" = "${screenshotScript} menu";
        "Sys_Req" = "${screenshotScript} full";
        "shift + Sys_Req" = "${screenshotScript} area";
        "super + shift + s" = "${screenshotScript} menu";
        "${mod} + ctrl + shift + s" = "${screenshotScript} gif";
        "XF86SelectiveScreenshot" = "${screenshotScript} area";
      }
      // lib.optionalAttrs (mod != "super") {
        "${mod} + shift + s" = "${screenshotScript} area";
      };

  volumeOsdPkg = writeShellApp {
    name = "volume-osd";
    runtimeInputs = [
      pkgs.dunst
      pkgs.pamixer
    ];
    text = builtins.readFile ./scripts/volume-osd.sh;
  };
  volumeOsd = lib.getExe volumeOsdPkg;

  brightnessOsdPkg = writeShellApp {
    name = "brightness-osd";
    runtimeInputs = [
      pkgs.brightnessctl
      pkgs.dunst
    ];
    text = builtins.readFile ./scripts/brightness-osd.sh;
  };
  brightnessOsd = lib.getExe brightnessOsdPkg;

  mediaControlPkg = writeShellApp {
    name = "bspwm-media-control";
    runtimeInputs = [
      pkgs.dunst
      pkgs.playerctl
    ];
    text = builtins.readFile ./scripts/bspwm-media-control.sh;
  };
  mediaControl = lib.getExe mediaControlPkg;

  colorPickerScriptPkg = writeShellApp {
    name = "bspwm-colorpicker";
    runtimeInputs = [
      pkgs.dunst
      pkgs.xclip
      pkgs.xcolor
    ];
    text = builtins.readFile ./scripts/bspwm-colorpicker.sh;
  };
  colorPickerScript = lib.getExe colorPickerScriptPkg;

  kbdBrightnessOsdPkg = writeShellApp {
    name = "kbd-brightness-osd";
    runtimeInputs = [
      pkgs.brightnessctl
      pkgs.dunst
      pkgs.solaar
    ];
    text = builtins.readFile ./scripts/kbd-brightness-osd.sh;
  };
  kbdBrightnessOsd = lib.getExe kbdBrightnessOsdPkg;

  pseudoTileScriptPkg = writeShellApp {
    name = "bspwm-toggle-pseudo-tile";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.dunst
    ];
    text = builtins.readFile ./scripts/bspwm-toggle-pseudo-tile.sh;
  };
  pseudoTileScript = lib.getExe pseudoTileScriptPkg;

  quickSettingsPkg = writeShellApp {
    name = "quick-settings";
    runtimeInputs = [
      pkgs.arandr
      pkgs.dunst
      pkgs.feh
      pkgs.lxappearance
      pkgs.networkmanagerapplet
      pkgs.nitrogen
      pkgs.pavucontrol
      pkgs.rofi
      pkgs.rofi-power-menu
      pkgs.xdg-utils
      pkgs.xrandr
      scratchpadScriptPkg
      screenshotScriptPkg
      colorPickerScriptPkg
      pseudoTileScriptPkg
    ];
    runtimeEnv = {
      BROWSER_CMD = browserLaunchCmd;
      TERMINAL_CMD = termCmd;
      TERMINAL_NAME = termDisplayName;
      MOD_NAME = modDisplayName;
      FILE_MANAGER_CMD = fmCmd;
    };
    text = builtins.readFile ./scripts/quick-settings.sh;
  };
  quickSettings = lib.getExe quickSettingsPkg;

  desktopFocusScriptPkg = writeShellApp {
    name = "bspwm-desktop-focus";
    runtimeInputs = [ pkgs.bspwm ];
    text = builtins.readFile ./scripts/bspwm-desktop-focus.sh;
  };
  desktopFocusScript = lib.getExe desktopFocusScriptPkg;

  desktopNodeScriptPkg = writeShellApp {
    name = "bspwm-node-to-desktop";
    runtimeInputs = [ pkgs.bspwm ];
    text = builtins.readFile ./scripts/bspwm-node-to-desktop.sh;
  };
  desktopNodeScript = lib.getExe desktopNodeScriptPkg;

  desktopRightClickScriptPkg = writeShellApp {
    name = "bspwm-desktop-right-click";
    runtimeInputs = [
      pkgs.xdotool
      pkgs.xprop
      quickSettingsPkg
    ];
    text = builtins.readFile ./scripts/bspwm-desktop-right-click.sh;
  };
  desktopRightClickScript = lib.getExe desktopRightClickScriptPkg;

  toggleDesktopScriptPkg = writeShellApp {
    name = "bspwm-toggle-desktop";
    runtimeInputs = [ pkgs.bspwm ];
    text = builtins.readFile ./scripts/bspwm-toggle-desktop.sh;
  };
  toggleDesktopScript = lib.getExe toggleDesktopScriptPkg;
in
{
  options.desktop.bspwm.sxhkd = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable sxhkd keybindings for bspwm";
    };

    modifierKey = mkOption {
      type = lib.types.str;
      default = config.desktop.bspwm.modifierKey or (config.desktop.modifierKey or "Super");
      description = "Tecla modificadora principal do SXHKD (ex: 'super', 'alt', 'ctrl').";
    };

    keybindings = mkOption {
      type = attrsOf str;
      default = { };
      description = "sxhkd keybindings adicionais ou customizadas.";
    };

    extraKeybindings = mkOption {
      type = attrsOf str;
      default = { };
      description = "Atalhos adicionais ou personalizados do SXHKD definidos no host.";
    };

    screenshotProfile = mkOption {
      type = lib.types.enum [
        "auto"
        "standard"
        "mac"
        "custom"
        "none"
      ];
      default = "auto";
      description = ''
        Perfil de teclas de atalho para captura de tela (screenshots):
        - "auto": detecta automaticamente (teclado Apple/Mac usa "mac", outros usam "standard").
        - "standard": ideal para PCs (Acer, Nitro, VMs, etc.) usando Print, Shift+Print, Ctrl+Print. Preserva Super+Shift+1..0 livres para workspaces!
        - "mac": estilo macOS usando Super+Shift+3/4/5 para telas/áreas de captura.
        - "custom": utiliza os atalhos declarados em screenshotKeybindings.
        - "none": desativa os atalhos de screenshot do sxhkd.
      '';
    };

    screenshotKeybindings = mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Mapeamento customizado de atalhos para captura de tela quando screenshotProfile = 'custom'.";
    };
  };

  config = mkIf cfg.enable {
    # Recarregar automaticamente o sxhkd ao rodar switch-home (sem reiniciar o bspwm)
    home.activation.reloadSxhkd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${pkgs.procps}/bin/pkill -USR1 -x sxhkd 2>/dev/null || (cd "$HOME" && ${pkgs.sxhkd}/bin/sxhkd &)
    '';

    services.sxhkd = {
      enable = true;
      package = pkgs.sxhkd;
      keybindings = {
        # =========================================================================
        # CENTRAL DE CONTROLE, PREFERÊNCIAS E AJUDA
        # =========================================================================
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

        # =========================================================================
        # FERRAMENTAS DE TELA E CORES
        # =========================================================================
        # Super + P: conta-gotas de cor (Colorpicker) - copia código HEX para a área de transferência
        "${mod} + p" = "${colorPickerScript}";
        # Super + Shift + P: menu completo de captura de tela com opções avançadas (ScreenShoTer via Rofi)
        "${mod} + shift + p" = "${screenshotScript} menu";

        # =========================================================================
        # LANÇADORES DE APLICATIVOS (ESTILO SPOTLIGHT / ROFI)
        # =========================================================================
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

        # =========================================================================
        # GERENCIAMENTO DE JANELAS (FECHAMENTO E ENCERRAMENTO)
        # =========================================================================
        # Super + Q: fecha a janela ativa normalmente (sinal de fechamento suave)
        "${mod} + q" = "bspc node -c";
        # Super + Shift + Q: força o encerramento imediato do processo da janela (kill)
        "${mod} + shift + q" = "bspc node -k";
        # Super + Shift + Escape: atalho de emergência para matar processo de janela travada
        "${mod} + shift + Escape" = "bspc node -k";

        # =========================================================================
        # ESTADOS DE JANELA (FLUTUANTE / TELA CHEIA / PSEUDO-TILED / MONOCLE)
        # =========================================================================
        # Super + F: alterna a janela entre modo flutuante (floating) e modo grade (tiling)
        "${mod} + f" = "bspc node -t '~floating'";
        # Super + S: atalho alternativo para alternar estado flutuante/tiling
        "${mod} + s" = "bspc node -t '~floating'";
        # Super + A: alterna a janela ativa em modo Tela Cheia (Fullscreen)
        "${mod} + a" = "bspc node -t '~fullscreen'";
        # Super + Shift + F: alterna o modo Pseudo-Tiled (janela na grade mas com tamanho natural original)
        "${mod} + shift + f" = "${pseudoTileScript}";
        # Super + Shift + T: atalho alternativo para o modo Pseudo-Tiled
        "${mod} + shift + t" = "${pseudoTileScript}";
        # Super + M: alterna o layout da área de trabalho atual para Monocle (janela maximizada individual)
        "${mod} + m" = "bspc desktop -l next";

        # =========================================================================
        # CAMADAS E SOBREPOSIÇÃO (PIP / SEMPRE NO TOPO)
        # =========================================================================
        # Super + =: coloca a janela focada na camada superior ('above' - sempre sobre as outras / Picture-in-Picture)
        "${mod} + equal" = "bspc node focused -l above";
        # Super + +: atalho alternativo para fixar a janela no topo
        "${mod} + plus" = "bspc node focused -l above";
        # Super + _: retorna a janela focada para a camada normal de sobreposição
        "${mod} + underscore" = "bspc node focused -l normal";

        # =========================================================================
        # MINIMIZAR / ESCONDER JANELAS E MOSTRAR ÁREA DE TRABALHO
        # =========================================================================
        # Super + Y: esconde/minimiza a janela ativa da tela
        "${mod} + y" = "bspc node -g hidden=on";
        # Super + Menos (-): atalho alternativo para minimizar/esconder a janela ativa
        "${mod} + minus" = "bspc node -g hidden=on";

        # Super + Shift + Y: desoculta e restaura o foco da última janela minimizada
        "${mod} + shift + y" = "bspc node any.hidden.local -g hidden=off -f";
        # Super + Shift + Menos (-): atalho alternativo para restaurar a janela minimizada
        "${mod} + shift + minus" = "bspc node any.hidden.local -g hidden=off -f";

        # Super + Shift + M: Mostrar Área de Trabalho (minimiza todas as janelas do workspace ou restaura todas)
        "${mod} + shift + m" = "${toggleDesktopScript}";

        # =========================================================================
        # BLOQUEIO DE SESSÃO E SEGURANÇA
        # =========================================================================
        # Super + Ctrl + Q: bloqueia a sessão do usuário com a tela de bloqueio
        "${mod} + ${ctrlMod} + q" = "bspwm-lock || loginctl lock-session";
        # Super + Shift + X: atalho alternativo para bloquear a tela
        "${mod} + shift + x" = "bspwm-lock || loginctl lock-session";
        # Super + Shift + L: atalho padrão de bloqueio de tela (Lock Screen)
        "${mod} + shift + l" = "bspwm-lock || loginctl lock-session";
        # Tecla de hardware ScreenSaver: aciona o bloqueador de tela
        "XF86ScreenSaver" = "bspwm-lock || loginctl lock-session";

        # =========================================================================
        # NAVEGAÇÃO E FOCO ENTRE JANELAS
        # =========================================================================
        # Super + H/J/K/L: navega o foco direcional entre janelas (Esquerda, Baixo, Cima, Direita - estilo Vim)
        "${mod} + {h,j,k,l}" = "bspc node -f {west,south,north,east}";
        # Super + Setas: navega o foco direcional entre janelas pelas teclas direcionais
        "${mod} + {Left,Down,Up,Right}" = "bspc node -f {west,south,north,east}";
        # Super + Shift + H/J/K/L: move e troca a posição da janela ativa com a janela vizinha (Vim)
        "${mod} + shift + {h,j,k,l}" = "bspc node -s {west,south,north,east}";
        # Super + Shift + Setas: move e troca a posição da janela ativa na direção das setas
        "${mod} + shift + {Left,Down,Up,Right}" = "bspc node -s {west,south,north,east}";

        # Super + Tab: cicla o foco para a próxima janela visível no workspace ativo
        "${mod} + Tab" = "bspc node -f next.local.!hidden.window || bspc node -f next.local.window";
        # Super + Shift + Tab: cicla o foco para a janela anterior no workspace ativo
        "${mod} + shift + Tab" = "bspc node -f prev.local.!hidden.window || bspc node -f prev.local.window";
        # Super + `: cicla o foco para a próxima janela (atalho alternativo estilo macOS)
        "${mod} + grave" = "bspc node -f next.local.!hidden.window || bspc node -f next.local.window";
        # Super + Shift + `: cicla o foco para a janela anterior
        "${mod} + shift + grave" =
          "bspc node -f prev.local.!hidden.window || bspc node -f prev.local.window";
        # Super + \: retorna o foco instantaneamente para a última janela focada anteriormente
        "${mod} + backslash" = "bspc node -f last.local.!hidden.window";

        # Super + Ctrl + Tab: troca a posição física da janela ativa com a próxima janela
        "${mod} + ctrl + Tab" = "bspc node -s next.local.!hidden.window";
        # Super + Ctrl + Shift + Tab: troca a posição física da janela ativa com a janela anterior
        "${mod} + ctrl + shift + Tab" = "bspc node -s prev.local.!hidden.window";
        # Super + Ctrl + `: troca de posição com a próxima janela
        "${mod} + ctrl + grave" = "bspc node -s next.local.!hidden.window";
        # Super + Ctrl + Shift + `: troca de posição com a janela anterior
        "${mod} + ctrl + shift + grave" = "bspc node -s prev.local.!hidden.window";

        # =========================================================================
        # NAVEGAÇÃO AVANÇADA NA ÁRVORE BSP (PAI E IRMÃO)
        # =========================================================================
        # Super + Ctrl + P: move o foco para o nó pai da árvore BSP (@parent)
        "${mod} + ctrl + p" = "bspc node -f @parent";
        # Super + Ctrl + B: move o foco para o nó irmão da árvore BSP (@brother)
        "${mod} + ctrl + b" = "bspc node -f @brother";
        # Super + Ctrl + Shift + P: troca de posição com o nó pai na árvore BSP
        "${mod} + ctrl + shift + p" = "bspc node -s @parent";
        # Super + Ctrl + Shift + B: troca de posição com o nó irmão na árvore BSP
        "${mod} + ctrl + shift + b" = "bspc node -s @brother";

        # =========================================================================
        # GERENCIAMENTO DINÂMICO DE LAYOUTS (BSP-LAYOUT)
        # =========================================================================
        # Super + Ctrl + Espaço: cicla para o próximo layout automático (Tall, Wide, Grid, Even, Monocle)
        "${mod} + ctrl + space" = "bsp-layout-switch next";
        # Super + Ctrl + Shift + Espaço: retorna para o layout anterior
        "${mod} + ctrl + shift + space" = "bsp-layout-switch prev";
        # Super + Ctrl + L: abre menu interativo no Rofi para escolher o layout do workspace
        "${mod} + ctrl + l" = "rofi-bsp-layout";
        # Super + Ctrl + T: aplica diretamente o layout 'Tall' (Master-Stack DWL)
        "${mod} + ctrl + t" = "bsp-layout-switch tall";
        # Super + Ctrl + C: aplica diretamente o layout 'Columns' (Colunas paralelas Niri)
        "${mod} + ctrl + c" = "bsp-layout-switch columns";
        # Super + Ctrl + Z: promove a janela ativa para Master (Zoom estilo DWL/DWM)
        "${mod} + ctrl + z" = "bsp-layout zoom";
        # Super + Ctrl + W: aplica diretamente o layout 'Wide' (linha mestre no topo)
        "${mod} + ctrl + w" = "bsp-layout-switch wide";
        # Super + Ctrl + G: aplica diretamente o layout 'Grid' (grade simétrica balanceada)
        "${mod} + ctrl + g" = "bsp-layout-switch grid";
        # Super + Ctrl + E: aplica diretamente o layout 'Even' (divisão perfeitamente igual)
        "${mod} + ctrl + e" = "bsp-layout-switch even";
        # Super + Ctrl + M: aplica diretamente o layout 'Monocle' (janela cheia)
        "${mod} + ctrl + m" = "bsp-layout-switch monocle";
        # Super + Ctrl + R: reseta a organização do workspace para o layout padrão
        "${mod} + ctrl + r" = "bsp-layout-switch reset";

        # =========================================================================
        # MULTI-MONITORES
        # =========================================================================
        # Super + [: move o foco para o monitor anterior
        "${mod} + bracketleft" = "bspc monitor -f prev";
        # Super + ]: move o foco para o próximo monitor
        "${mod} + bracketright" = "bspc monitor -f next";
        # Super + Shift + [: move a janela ativa para o monitor anterior e acompanha o foco
        "${mod} + shift + bracketleft" = "bspc node -m prev --follow";
        # Super + Shift + ]: move a janela ativa para o próximo monitor e acompanha o foco
        "${mod} + shift + bracketright" = "bspc node -m next --follow";

        # =========================================================================
        # ÁREAS DE TRABALHO / WORKSPACES (1 A 10, ONDE 0 É O WORKSPACE 10)
        # =========================================================================
        # Super + [1-9,0]: muda o foco para a área de trabalho 1 a 10
        "${mod} + {1-9,0}" = "${desktopFocusScript} {1-9,0}";
        # Super + Shift + [1-9,0]: move a janela focada para a área 1 a 10 e muda o foco junto (--follow)
        "${mod} + shift + {1-9,0}" = "${desktopNodeScript} {1-9,0} true";
        # Super + Ctrl + [1-9,0]: move a janela para a área 1 a 10 em segundo plano (sem mudar o foco da tela)
        "${mod} + ctrl + {1-9,0}" = "${desktopNodeScript} {1-9,0} false";

        # =========================================================================
        # REDIMENSIONAMENTO DE JANELAS (EXPANDIR / CONTRAIR)
        # =========================================================================
        # Super + Ctrl + Setas: redimensionamento inteligente (expande ou contrai conforme a posição da janela)
        "${mod} + ctrl + {Left,Down,Up,Right}" = "${resizeScript} {left,down,up,right}";
        # Super + Ctrl + H/J/K/L: redimensionamento inteligente usando as teclas Vim
        "${mod} + ctrl + {h,j,k,l}" = "${resizeScript} {left,down,up,right}";
        # Super + Ctrl + Shift + H/J/K/L: atalho alternativo Vim
        "${mod} + ctrl + shift + {h,j,k,l}" = "${resizeScript} {left,down,up,right}";

        # =========================================================================
        # REINICIALIZAÇÃO DO AMBIENTE
        # =========================================================================
        # Super + Shift + R: recarrega o BSPWM, reinicia o SXHKD e reabre a Polybar
        "${mod} + shift + r" = "bspc wm -r; ${pkgs.procps}/bin/pkill -USR1 -x sxhkd; polybar-launch &";
        # Super + Escape: recarrega o daemon de atalhos SXHKD sem reiniciar a sessão
        "${mod} + Escape" = "${pkgs.procps}/bin/pkill -USR1 -x sxhkd";

        # =========================================================================
        # CONTROLES DE VOLUME E MÍDIA (COM OSD DUNST)
        # =========================================================================
        # Tecla Volume Up: aumenta o volume em 2% com feedback visual OSD
        "XF86AudioRaiseVolume" = "${volumeOsd} up";
        # Tecla Volume Down: diminui o volume em 2% com feedback visual OSD
        "XF86AudioLowerVolume" = "${volumeOsd} down";
        # Tecla Mute: ativa/desativa o mudo com feedback visual OSD
        "XF86AudioMute" = "${volumeOsd} mute";
        # Tecla Play/Pause: alterna reprodução/pausa de áudio/vídeo
        "XF86AudioPlay" = "${mediaControl} play-pause";
        # Tecla Next: avança para a próxima faixa de mídia
        "XF86AudioNext" = "${mediaControl} next";
        # Tecla Previous: retrocede para a faixa de mídia anterior
        "XF86AudioPrev" = "${mediaControl} prev";
        # Tecla Stop: interrompe a reprodução de mídia
        "XF86AudioStop" = "${mediaControl} stop";

        # =========================================================================
        # CONTROLES DE BRILHO DA TELA
        # =========================================================================
        # Tecla Brilho + (F2 / Fn+F2): aumenta o brilho da tela em 2% com OSD
        "XF86MonBrightnessUp" = "${brightnessOsd} up";
        # Tecla Brilho - (F1 / Fn+F1): diminui o brilho da tela em 2% com OSD
        "XF86MonBrightnessDown" = "${brightnessOsd} down";

        # =========================================================================
        # CONTROLES DE ILUMINAÇÃO DO TECLADO (NOTEBOOKS E LOGITECH MX KEYS)
        # =========================================================================
        # Tecla Hardware Iluminação +: aumenta o brilho do teclado
        "XF86KbdBrightnessUp" = "${kbdBrightnessOsd} up";
        # Tecla Hardware Iluminação -: diminui o brilho do teclado
        "XF86KbdBrightnessDown" = "${kbdBrightnessOsd} down";
        # Tecla Hardware Alternar Luz: liga/desliga a luz do teclado
        "XF86KbdLightOnOff" = "${kbdBrightnessOsd} toggle";

        # Super + F6 (ou Fn+F6 em MacBook): aumenta luz do teclado
        "${mod} + F6" = "${kbdBrightnessOsd} up";
        # Super + F5 (ou Fn+F5 em MacBook): diminui luz do teclado
        "${mod} + F5" = "${kbdBrightnessOsd} down";
        # Super + Shift + F5: alterna luz do teclado
        "${mod} + shift + F5" = "${kbdBrightnessOsd} toggle";

        # Super + F4 (Logitech MX Keys / teclados padrão): aumenta luz do teclado
        "${mod} + F4" = "${kbdBrightnessOsd} up";
        # Super + F3 (Logitech MX Keys / teclados padrão): diminui luz do teclado
        "${mod} + F3" = "${kbdBrightnessOsd} down";
        # Super + Shift + F4: alterna luz do teclado (Logitech MX Keys)
        "${mod} + shift + F4" = "${kbdBrightnessOsd} toggle";
      }
      // screenshotBindings
      //
        lib.optionalAttrs (config.desktop.bspwm.polybar.enable && config.desktop.bspwm.polybar.tray.enable)
          {
            # Bandeja do Sistema Stalonetray (oculta/exibe)
            "${mod} + i" = "stalonetray-toggle";
            "${mod} + shift + i" = "stalonetray-toggle";
          }
      // lib.optionalAttrs (mod == "super") {
        # Super + Alt + Setas / H,J,K,L: redimensionamento rápido tradicional de janelas
        "super + alt + {Left,Down,Up,Right}" = "${resizeScript} {left,down,up,right}";
        "super + alt + {h,j,k,l}" = "${resizeScript} {left,down,up,right}";
      }
      // (config.desktop.bspwm.extraKeybindings or { })
      // cfg.keybindings
      // cfg.extraKeybindings;
    };

    # Utilitários de linha de comando para uso interativo e scripts
    home.packages = [
      pseudoTileScriptPkg
      (pkgs.writeShellScriptBin "bspwm-pseudo-tile" ''exec ${pseudoTileScript} "$@"'')
      screenshotScriptPkg
      (pkgs.writeShellScriptBin "screenshoter" ''exec ${screenshotScript} "$@"'')
      resizeScriptPkg
      colorPickerScriptPkg
      mediaControlPkg
    ];
  };
}
