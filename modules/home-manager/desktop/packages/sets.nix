# Conjuntos reutilizáveis de pacotes para ambientes desktop (X11 e Wayland).
# Consumido por BSPWM, DWM, Hyprland e MangoWM.
{
  pkgs,
}:
rec {
  # --- Ferramentas e utilitários essenciais compartilhados entre desktops X11 (BSPWM, DWM) ---
  x11-core = with pkgs; [
    xdotool
    wmctrl
    xprop
    xset
    xsetroot
    xrandr
    xrdb
    xinput
    xss-lock
    glib
    dconf
    xkbset
    feh
    bc
    jq
    networkmanagerapplet
    pavucontrol
    pamixer
    playerctl
    brightnessctl
    galculator
    libnotify
  ];

  # Pacotes de compatibilidade X11 para distribuições não-NixOS (Debian/Fedora/standalone)
  x11-standalone = with pkgs; [
    glibcLocales
    at-spi2-atk
    xinit
    libxcomposite
    libxinerama
    libxcb
    xdpyinfo
    xkill
    xwininfo
    xdg-utils
    xdg-user-dirs
    xdg-desktop-portal-gtk
    dialog
  ];

  # --- Utilitários essenciais compartilhados entre compositores Wayland (Hyprland, MangoWM) ---
  wayland-core = with pkgs; [
    pavucontrol
    pamixer
    playerctl
    brightnessctl
    libnotify
    networkmanagerapplet
    galculator
    xdg-utils
  ];

  # Pacotes de compatibilidade Wayland para distribuições não-NixOS
  wayland-standalone = with pkgs; [
    glibcLocales
    xdg-desktop-portal-gtk
  ];

  # --- Gerenciamento de Clipboard ---
  clipboard = {
    x11 = with pkgs; [
      xclip
      xsel
    ];
    wayland = with pkgs; [
      wl-clipboard
      cliphist
    ];
  };

  # --- Captura de Tela (Screenshot) ---
  screenshot = {
    x11 = with pkgs; [
      maim
      slop
      xcolor
    ];
    wayland = with pkgs; [
      grim
      slurp
      swappy
    ];
  };

  # --- Notificações ---
  notifications = with pkgs; [
    libnotify
  ];

  # --- Launchers e Menus de Aplicações ---
  launcher = {
    x11 = with pkgs; [
      rofi
      rofi-power-menu
      dmenu
    ];
    wayland = with pkgs; [
      rofi-wayland
    ];
  };

  # --- Tipografia e Fontes de Interface / Símbolos / CJK ---
  fonts = with pkgs; [
    inter
    cantarell-fonts
    noto-fonts-cjk-sans
    ipafont
  ];

  # --- Conjuntos consolidados padrão (sets completos por servidor gráfico) ---
  x11 = x11-core ++ clipboard.x11 ++ screenshot.x11 ++ notifications ++ fonts;
  wayland = wayland-core ++ clipboard.wayland ++ screenshot.wayland ++ notifications ++ fonts;
}
