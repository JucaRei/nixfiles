{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.system.programs.terminal;
  urxvtCfg = config.system.programs.terminal.urxvt;

  # rxvt-unicode com todos os plugins disponíveis empacotados (perls, resize-font, vtwheel, urxvt-tabbedex, etc.)
  # e symlinks bidirecionais para compatibilidade com atalhos de resize-font e font-size.
  baseRxvt = pkgs.rxvt-unicode.override {
    configure =
      { availablePlugins, ... }:
      {
        plugins = builtins.attrValues availablePlugins;
      };
  };

  rxvtPackage = pkgs.symlinkJoin {
    name = "urxvt-custom-${baseRxvt.version or "9.31"}";
    paths = [ baseRxvt ];
    postBuild = ''
      if [ -d "$out/lib/urxvt/perl" ]; then
        if [ -L "$out/lib/urxvt/perl" ]; then
          perl_src="$(readlink -f "$out/lib/urxvt/perl")"
          rm "$out/lib/urxvt/perl"
          mkdir -p "$out/lib/urxvt/perl"
          cp -rs "$perl_src"/* "$out/lib/urxvt/perl/"
        fi
        if [ -e "$out/lib/urxvt/perl/resize-font" ] && [ ! -e "$out/lib/urxvt/perl/font-size" ]; then
          ln -sf resize-font "$out/lib/urxvt/perl/font-size"
        fi
        if [ -e "$out/lib/urxvt/perl/font-size" ] && [ ! -e "$out/lib/urxvt/perl/resize-font" ]; then
          ln -sf font-size "$out/lib/urxvt/perl/resize-font"
        fi
      fi
    '';
  };

  anonymousProPkg = pkgs.anonymous-pro-fonts or pkgs.anonymousPro;
  hackFontPkg = pkgs.hack-font;
  hackNerdFontPkg = pkgs.nerd-fonts.hack;
  jetbrainsMonoNerdFontPkg = pkgs.nerd-fonts.jetbrains-mono;
  symbolsNerdFontPkg = pkgs.nerd-fonts.symbols-only;
in
{
  options = {
    system.programs.terminal.urxvt = {
      enable = mkEnableOption "URxvt (rxvt-unicode) terminal emulator with Gruvbox colors and tabbedex/clipboard/vtwheel extensions.";
    };
  };

  config = mkIf ((cfg.enable && (cfg.name == "urxvt" || cfg.name == "rxvt")) || urxvtCfg.enable) {
    home.packages = [
      rxvtPackage
      pkgs.xrdb
      hackNerdFontPkg
      jetbrainsMonoNerdFontPkg
      symbolsNerdFontPkg
      hackFontPkg
      anonymousProPkg
    ];

    # Wrapper de inicialização: recarrega Xresources e conecta ao daemon urxvtd com fallback automático
    home.file.".local/bin/term" = {
      executable = true;
      text = ''
        #!/bin/sh

        ${pkgs.xrdb}/bin/xrdb -merge ~/.Xresources

        ${rxvtPackage}/bin/urxvtc "$@"
        if [ $? -eq 2 ]; then
          ${rxvtPackage}/bin/urxvtd -q -o -f
          ${rxvtPackage}/bin/urxvtc "$@"
        fi
      '';
    };

    # Atalhos de Desktop Freedesktop (.desktop) para rxvt e urxvt
    xdg.desktopEntries = {
      rxvt = {
        name = "Terminal";
        genericName = "Terminal Emulator";
        comment = "URxvt Terminal Emulator";
        exec = "${config.home.homeDirectory}/.local/bin/term %U";
        icon = "utilities-terminal";
        terminal = false;
        startupNotify = true;
        type = "Application";
        categories = [
          "System"
          "TerminalEmulator"
        ];
      };
      urxvt = {
        name = "URxvt";
        genericName = "Terminal Emulator";
        comment = "URxvt Terminal Emulator";
        exec = "${config.home.homeDirectory}/.local/bin/term %U";
        icon = "utilities-terminal";
        terminal = false;
        startupNotify = true;
        type = "Application";
        categories = [
          "System"
          "TerminalEmulator"
        ];
      };
    };

    # Paleta de cores Gruvbox 256
    xresources.extraConfig = ''
      ! -----------------------------------------------------------------------------
      ! File: gruvbox-urxvt256.xresources
      ! Description: Retro groove colorscheme generalized
      ! Author: morhetz <morhetz@gmail.com>
      ! Source: https://github.com/morhetz/gruvbox-generalized
      ! Last Modified: 13 Dec 2013
      ! -----------------------------------------------------------------------------
      URxvt.color24:  #076678
      URxvt.color66:  #427b58
      URxvt.color88:  #9d0006
      URxvt.color96:  #8f3f71
      URxvt.color100: #79740e
      URxvt.color108: #8ec07c
      URxvt.color109: #83a598
      URxvt.color130: #af3a03
      URxvt.color136: #b57614
      URxvt.color142: #b8bb26
      URxvt.color167: #fb4934
      URxvt.color175: #d3869b
      URxvt.color208: #fe8019
      URxvt.color214: #fabd2f
      URxvt.color223: #ebdbb2
      URxvt.color228: #f2e5bc
      URxvt.color229: #fbf1c7
      URxvt.color230: #f9f5d7
      URxvt.color234: #1d2021
      URxvt.color235: #282828
      URxvt.color236: #32302f
      URxvt.color237: #3c3836
      URxvt.color239: #504945
      URxvt.color241: #665c54
      URxvt.color243: #7c6f64
      URxvt.color244: #928374
      URxvt.color245: #928374
      URxvt.color246: #a89984
      URxvt.color248: #bdae93
      URxvt.color250: #d5c4a1
    '';

    # Configurações de comportamento, abas, clipboard, atalhos e fontes
    xresources.properties = {
      # colors
      "*background" = "#32302f";
      "*foreground" = "#ebdbb2";
      "*color0" = "#282828";
      "*color1" = "#cc241d";
      "*color2" = "#98971a";
      "*color3" = "#d79921";
      "*color4" = "#458588";
      "*color5" = "#b16286";
      "*color6" = "#689d6a";
      "*color7" = "#a89984";
      "*color8" = "#928374";
      "*color9" = "#fb4934";
      "*color10" = "#b8bb26";
      "*color11" = "#fabd2f";
      "*color12" = "#83a598";
      "*color13" = "#d3869b";
      "*color14" = "#8ec07c";
      "*color15" = "#ebdbb2";

      # extensions i use
      "URxvt.perl-ext-common" = "default,clipboard,matcher,tabbedex,vtwheel";
      "URxvt.perl-lib" = "${rxvtPackage}/lib/urxvt/perl";

      # transparency
      "URxvt*depth" = "32";

      # URL opening
      "URxvt.url-launcher" = "${pkgs.xdg-utils}/bin/xdg-open";
      "URxvt.keysym.C-Delete" = "perl:matcher:last";
      "URxvt.keysym.M-Delete" = "perl:matcher:list";
      "URxvt.matcher.button" = "1";

      # Tabs
      "URxvt.tabbedex.autohide" = "false";
      "URxvt.tabbedex.reopen-on-close" = "no";
      "URxvt.keysym.Control-t" = "perl:tabbedex:new_tab";
      "URxvt.keysym.Control-Tab" = "perl:tabbedex:next_tab";
      "URxvt.keysym.Control-Shift-Tab" = "perl:tabbedex:prev_tab";
      "URxvt.keysym.Control-Shift-Left" = "perl:tabbedex:move_tab_left";
      "URxvt.keysym.Control-Shift-Right" = "perl:tabbedex:move_tab_right";
      "URxvt.keysym.Control-Shift-R" = "perl:tabbedex:rename_tab";
      "URxvt.tabbedex.no-tabbedex-keys" = "true";
      "URxvt.tabbedex.new-button" = "yes";

      # Clipboard
      "URxvt.clipboard.autocopy" = "true";
      "URxvt.keysym.Shift-M-C" = "perl:clipboard:copy";
      "URxvt.keysym.Shift-M-V" = "perl:clipboard:paste";

      # Font-size
      "URxvt.keysym.C-Up" = "perl:font-size:increase";
      "URxvt.keysym.C-Down" = "perl:font-size:decrease";
      "URxvt.keysym.C-S-Up" = "perl:font-size:incglobal";
      "URxvt.keysym.C-S-Down" = "perl:font-size:decglobal";
      "URxvt.keysym.C-equal" = "perl:font-size:reset";
      "URxvt.keysym.C-slash" = "perl:font-size:show";

      # Hacks & Geometria
      "URxvt.scrollBar" = "false";
      "URxvt.iso14755" = "false";
      "URxvt.iso14755_52" = "false";
      "URxvt.geometry" = "100x50";
      "URxvt.depth" = "32";
      "URxvt.background" = "[95]#32302f";
      "URxvt.skipBuiltinGlyphs" = "false";

      # Espaçamento (alinha ícones Nerd Font perfeitamente e evita corte/distorção)
      "URxvt.letterSpace" = "-1";
      "URxvt.lineSpace" = "0";

      # Fontes & Fallbacks para glifos Nerd Fonts, ícones de arquivo e símbolos Powerline
      "URxvt.font" = "xft:Hack Nerd Font:size=12,xft:JetBrainsMono Nerd Font:size=12,xft:Symbols Nerd Font Mono:size=12,xft:Hack:size=12,xft:Noto Color Emoji:size=12";
      "URxvt.boldFont" = "xft:Hack Nerd Font:bold:size=12,xft:JetBrainsMono Nerd Font:bold:size=12,xft:Symbols Nerd Font Mono:size=12,xft:Hack:bold:size=12";
      "URxvt.italicFont" = "xft:Hack Nerd Font:italic:size=12,xft:JetBrainsMono Nerd Font:italic:size=12,xft:Symbols Nerd Font Mono:size=12,xft:Hack:italic:size=12";
      "URxvt.boldItalicFont" = "xft:Hack Nerd Font:bold:italic:size=12,xft:JetBrainsMono Nerd Font:bold:italic:size=12,xft:Symbols Nerd Font Mono:size=12,xft:Hack:bold:italic:size=12";
    };

    # Daemon urxvtd via systemd do usuário
    systemd.user.services.urxvtd = {
      Unit = {
        Description = "Urxvt Terminal Daemon";
        Documentation = "man:urxvtd(1) man:urxvt(1)";
      };

      Service = {
        ExecStart = "${rxvtPackage}/bin/urxvtd -o -q";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # Recarrega recursos do X11 e reinicia o daemon urxvtd para atualizar as fontes imediatamente
    home.activation.reloadUrxvt = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.xrdb}/bin/xrdb -merge "$HOME/.Xresources" 2>/dev/null || true
      if systemctl --user is-active --quiet urxvtd.service 2>/dev/null; then
        systemctl --user restart urxvtd.service 2>/dev/null || true
      else
        pkill -x urxvtd 2>/dev/null || true
      fi
    '';
  };
}
