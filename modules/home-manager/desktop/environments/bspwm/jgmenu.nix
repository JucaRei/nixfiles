{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.bspwm.jgmenu;
in
{
  options.desktop.bspwm.jgmenu = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable jgmenu desktop context menu for bspwm";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      jgmenu
      arandr
      lxappearance
      feh
    ];

    xdg.configFile."jgmenu/jgmenurc".text = ''
      # --- Configuração Geral do jgmenu (Catppuccin Mocha Style) ---
      stay_alive           = 0
      position_mode        = pointer
      edge_snap_x          = 30
      terminal_exec        = ${pkgs.alacritty}/bin/alacritty
      terminal_args        = -e

      # --- Dimensões e Layout ---
      menu_margin_x        = 4
      menu_margin_y        = 4
      menu_width           = 230
      menu_height_min      = 0
      menu_height_max      = 0
      menu_radius          = 8
      menu_border          = 1
      menu_pad_x           = 8
      menu_pad_y           = 8
      item_margin_x        = 3
      item_margin_y        = 3
      item_height          = 28
      item_padding_x       = 8
      item_radius          = 4
      item_border          = 0

      # --- Fontes e Ícones ---
      font                 = Inter 10
      icon_size            = 20
      icon_theme           = Papirus-Dark
      icon_theme_fallback  = hicolor

      # --- Cores (Catppuccin Mocha) ---
      color_menu_bg        = #1e1e2e 95
      color_menu_border    = #89b4fa 100
      color_norm_bg        = #1e1e2e 0
      color_norm_fg        = #cdd6f4 100
      color_sel_bg         = #313244 100
      color_sel_fg         = #89b4fa 100
      color_sep_fg         = #45475a 100
      color_scroll_ind     = #585b70 100

      # --- Submenus e Efeitos ---
      csv_name_format      = %n
      sub_hover_action     = 1
      sub_spacing          = 4
    '';

    xdg.configFile."jgmenu/prepend.csv".text = ''
      @net,Conexões & Wi-Fi,nm-connection-editor,network-wireless
      @disp,Resolução da Tela,^checkout(resolution),preferences-desktop-display
      @sound,Controle de Áudio,pavucontrol,multimedia-volume-control
      @theme,Aparência & Temas,lxappearance,preferences-desktop-theme
      @wall,Papel de Parede,nitrogen,preferences-desktop-wallpaper
      ^sep()
      @files,Gerenciador de Arquivos,thunar,system-file-manager
      @term,Abrir Terminal,alacritty,utilities-terminal
      ^sep()
      @reload,Recarregar BSPWM,bspc wm -r,view-refresh
      @lock,Bloquear Sessão,loginctl lock-session,system-lock-screen
      @power,Menu de Energia,rofi -show power-menu -modi "power-menu:rofi-power-menu",system-shutdown

      ^tag(resolution)
      1920x1080 (Full HD),xrandr -s 1920x1080,video-display
      2560x1440 (Quad HD 2K),xrandr -s 2560x1440,video-display
      1600x900 (HD+),xrandr -s 1600x900,video-display
      1366x768 (HD),xrandr -s 1366x768,video-display
      Painel Avançado (ARandR),arandr,preferences-desktop-display
    '';
  };
}
