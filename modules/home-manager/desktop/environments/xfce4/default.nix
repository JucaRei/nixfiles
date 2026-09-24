{
  config,
  lib,
  pkgs,
  desktop ? null,
  ...
}:
let
  inherit (lib) mkIf getExe mkOption;
  terminalBin =
    if config.programs ? alacritty && config.programs.alacritty.enable then
      getExe config.programs.alacritty.package
    else
      "${pkgs.xfce4-terminal or pkgs.alacritty}/bin/xfce4-terminal";

  cfg = config.desktop.xfce4;
  normMod =
    let
      k = lib.toLower (cfg.modifierKey or (config.desktop.modifierKey or "super"));
    in
    if k == "super" || k == "mod4" then
      "Super"
    else if k == "alt" || k == "mod1" then
      "Alt"
    else if k == "ctrl" || k == "control" then
      "Primary"
    else
      "Super";

  xfceMod = "<${normMod}>";
  altMod = if normMod == "Alt" then "<Super>" else "<Alt>";
in
{
  options.desktop.xfce4 = {
    modifierKey = mkOption {
      type = lib.types.enum [
        "Super"
        "Alt"
        "Ctrl"
        "super"
        "alt"
        "ctrl"
        "SUPER"
        "ALT"
        "CTRL"
        "Mod4"
        "Mod1"
        "mod4"
        "mod1"
      ];
      default = config.desktop.modifierKey or "Super";
      description = ''
        Tecla modificadora principal (Super Key / Mod Key) para o XFCE4.
        Padrão herda de desktop.modifierKey ("Super").
      '';
    };
  };

  config = mkIf (desktop == "xfce4") {
    desktop.display-servers.backend = "x11";

    # --- Programas Padrão do XFCE ---
    system.programs = {
      file-manager.thunar.enable = lib.mkDefault (
        !config.system.programs.file-manager.nautilus.enable
        && !config.system.programs.file-manager.nemo.enable
        && !config.system.programs.file-manager.pcmanfm.enable
      );
    };

    # --- Tema e Aparência GTK (Catppuccin Mocha + Papirus Dark) ---
    gtk = {
      enable = true;
      theme = {
        name = "catppuccin-mocha-blue-standard+rimless";
        package = pkgs.catppuccin-gtk.override {
          accents = [ "blue" ];
          size = "standard";
          tweaks = [ "rimless" ];
          variant = "mocha";
        };
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "catppuccin-mocha-dark-cursors";
        package = pkgs.catppuccin-cursors.mochaDark;
        size = 24;
      };
      font = {
        name = "Inter";
        size = 10;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
        gtk-cursor-theme-size = 24;
      };
      gtk4 = {
        theme = config.gtk.theme;
        extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };
    };

    # --- Configurações Declarativas do XFCE (Xfconf) ---
    xfconf.settings = {
      # Gerenciador de Janelas (XFWM4)
      xfwm4 = {
        "general/theme" = config.gtk.theme.name;
        "general/title_font" = "Inter Bold 10";
        "general/button_layout" = "O|HMC";
        "general/box_move" = false;
        "general/box_resize" = false;
        "general/use_compositing" = true;
        "general/show_dock_shadow" = true;
        "general/show_frame_shadow" = true;
        "general/show_popup_shadow" = true;
        "general/cycle_workspaces" = true;
        "general/workspace_count" = 4;
        "general/snap_to_border" = true;
        "general/snap_to_windows" = true;
      };

      # Aparência global e fontes (Xsettings)
      xsettings = {
        "Net/ThemeName" = config.gtk.theme.name;
        "Net/IconThemeName" = "Papirus-Dark";
        "Gtk/CursorThemeName" = config.gtk.cursorTheme.name;
        "Gtk/CursorThemeSize" = 24;
        "Gtk/FontName" = "Inter 10";
        "Gtk/MonospaceFontName" = "SFMono Nerd Font 10";
        "Gtk/DecorationLayout" = ":minimize,maximize,close";
        "Xft/Antialias" = 1;
        "Xft/Hinting" = 1;
        "Xft/HintStyle" = "hintslight";
        "Xft/RGBA" = "rgb";
      };

      # Atalhos de Teclado
      xfce4-keyboard-shortcuts = {
        "commands/custom/${xfceMod}Return" = terminalBin;
        "commands/custom/${xfceMod}t" = terminalBin;
        "commands/custom/${xfceMod}e" = config.system.programs.file-manager.activeCommand or "file-manager";
        "commands/custom/${xfceMod}f" = config.system.programs.file-manager.activeCommand or "file-manager";
        "commands/custom/${xfceMod}r" = "${pkgs.xfce4-appfinder}/bin/xfce4-appfinder";
        "commands/custom/${xfceMod}space" = "${pkgs.xfce4-appfinder}/bin/xfce4-appfinder";
        "commands/custom/Print" = "${pkgs.xfce4-screenshooter}/bin/xfce4-screenshooter -f";
        "commands/custom/${altMod}Print" = "${pkgs.xfce4-screenshooter}/bin/xfce4-screenshooter -w";
        "commands/custom/<Shift>Print" = "${pkgs.xfce4-screenshooter}/bin/xfce4-screenshooter -r";
        "commands/custom/${xfceMod}l" = "${pkgs.xfce4-session}/bin/xflock4";
      };

      # Gestão de Energia
      xfce4-power-manager = {
        "xfce4-power-manager/power-button-action" = 4; # Perguntar
        "xfce4-power-manager/lid-action-on-ac" = 1; # Suspender
        "xfce4-power-manager/lid-action-on-battery" = 1; # Suspender
        "xfce4-power-manager/show-tray-icon" = true;
      };

      # Desktop e Ícones
      xfce4-desktop = {
        "desktop-icons/file-icons/show-home" = true;
        "desktop-icons/file-icons/show-trash" = true;
        "desktop-icons/file-icons/show-removable" = true;
        "desktop-icons/file-icons/show-filesystem" = false;
        "desktop-icons/single-click" = false;
      };

      # Gerenciador de Arquivos (Thunar)
      thunar = {
        "last-view" = "ThunarDetailsView";
        "last-show-hidden" = true;
        "misc-single-click" = false;
        "misc-remember-geometry" = true;
        "misc-folders-first" = true;
      };
    };

    home = {
      packages = with pkgs; [
        # File Manager Helpers & Search
        xfce4-exo
        catfish

        # Temas e Fontes
        catppuccin-gtk
        papirus-icon-theme
        catppuccin-cursors.mochaDark
        inter

        # Utilitários e Plugins do Painel
        xfce4-whiskermenu-plugin
        xfce4-pulseaudio-plugin
        xfce4-screenshooter
        xfce4-clipman-plugin
        xfce4-taskmanager
        xfce4-sensors-plugin
        xfce4-cpufreq-plugin
        xfce4-netload-plugin
        xfce4-docklike-plugin
        ristretto
        mousepad
        pavucontrol
        networkmanagerapplet

        # Arquivos compactados e Thumbnails adicionais
        zip
        unzip
        libgepub
        ffmpegthumbnailer

        # Ferramentas do sistema
        gnome-keyring
        gparted
        galculator
        libnotify
      ];

      file = {
        ".config/xfce4/helpers.rc".text = ''
          TerminalEmulatorDismissed=true
        '';
      };
    };
  };
}
