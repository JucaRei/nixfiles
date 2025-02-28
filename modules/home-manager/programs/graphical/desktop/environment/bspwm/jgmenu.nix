{ pkgs, lib, config, ... }: {
  home.packages = with pkgs; [ jgmenu ];

  xdg.configFile = {
    "jgmenu/jgmenurc".text = ''
      position_mode = pointer
      stay_alive = 0
      tint2_look = 0
      terminal_exec = ${lib.getExe config.programs.alacritty.package}
      terminal_args = -e
      menu_width = 160
      menu_padding_top = 5
      menu_padding_right = 5
      menu_padding_bottom = 5
      menu_padding_left = 5
      menu_radius = 8
      menu_border = 0
      menu_halign = left
      sub_hover_action = 1
      item_margin_y = 5
      item_height = 30
      item_padding_x = 8
      item_radius = 6
      item_border = 0
      sep_height = 2
      font = Clarity City Bold 12px
      icon_size = 16
      icon_theme = Papirus-Dark
      arrow_string = 󰄾
      color_menu_border = #ffffff 0
      color_menu_bg = #1a1b26
      color_norm_bg = #ffffff 0
      color_norm_fg = #c0caf5
      color_sel_bg = #222330
      color_sel_fg = #c0caf5
      color_sep_fg = #414868
    '';

    "jgmenu/scripts/menu.txt" = {
      text = ''
        Terminal,${lib.getExe config.programs.alacritty.package},${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/terminal.svg
        Web Browser,firefox --browser,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/internet-web-browser.svg
        File Manager,thunar ,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/org.xfce.thunar.svg

        ^sep()

        Favorites,^checkout(favorites),${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/status/starred.svg

        ^sep()

        Widgets,^checkout(wg),${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/kmenuedit.svg
        BSPWM,^checkout(wm),${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/gnome-windows.svg
        Exit,^checkout(exit),${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/system-shutdown.svg

        ^tag(favorites)
        Editor,OpenApps --editor,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/standard-notes.svg
        Neovim,OpenApps --nvim,nvim
        # Firefox,OpenApps --browser,brave
        # Brave,brave ,brave
        Firefox,firefox ,firefox
        Retroarch,retroarch,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/retroarch.svg

        ^tag(wg)
        User Card,OpenApps --usercard,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/system-users.svg
        Music Player,OpenApps --player,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/musique.svg
        Power Menu,OpenApps --powermenu,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/status/changes-allow.svg
        Calendar,OpenApps --calendar,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/office-calendar.svg

        ^tag(wm)
        Change Theme,OpenApps --rice,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/colors.svg
        Keybinds,KeybindingsHelp,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/preferences-desktop-keyboard-shortcuts.svg
        Restart WM,bspc wm -r,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/system-reboot.svg
        Quit,bspc quit,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/system-log-out.svg

        ^tag(exit)
        Block computer,physlock -d,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/status/changes-prevent.svg
        Reboot,systemctl reboot,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/system-reboot.svg
        Shutdown,systemctl poweroff,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/system-shutdown.svg
      '';
    };
  };
}
