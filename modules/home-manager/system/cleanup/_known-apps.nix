# Declarative registry of known applications and their config/cache paths.
{ config }:

[
  # --- Gerenciadores de Arquivos ---
  {
    name = "spacefm";
    enabled = false; # Removido permanentemente
    configs = [ "$HOME/.config/spacefm" ];
    caches = [ "$HOME/.cache/spacefm" ];
    data = [ "$HOME/.local/share/spacefm" ];
    desktops = [ "$HOME/.local/share/applications/spacefm*.desktop" ];
  }
  {
    name = "thunar";
    enabled = config.system.programs.file-manager.thunar.enable or false;
    configs = [
      "$HOME/.config/Thunar"
      "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"
    ];
    caches = [ "$HOME/.cache/Thunar" ];
    data = [ "$HOME/.local/share/Thunar" ];
    desktops = [
      "$HOME/.local/share/applications/thunar*.desktop"
      "$HOME/.local/share/applications/Thunar*.desktop"
    ];
  }
  {
    name = "nautilus";
    enabled = config.system.programs.file-manager.nautilus.enable or false;
    configs = [ "$HOME/.config/nautilus" ];
    caches = [ "$HOME/.cache/nautilus" ];
    data = [ "$HOME/.local/share/nautilus" ];
    desktops = [ "$HOME/.local/share/applications/org.gnome.Nautilus*.desktop" ];
  }
  {
    name = "nemo";
    enabled = config.system.programs.file-manager.nemo.enable or false;
    configs = [ "$HOME/.config/nemo" ];
    caches = [ "$HOME/.cache/nemo" ];
    data = [ "$HOME/.local/share/nemo" ];
    desktops = [ "$HOME/.local/share/applications/nemo*.desktop" ];
  }
  {
    name = "pcmanfm";
    enabled = config.system.programs.file-manager.pcmanfm.enable or false;
    configs = [ "$HOME/.config/pcmanfm" ];
    caches = [ "$HOME/.cache/pcmanfm" ];
    data = [ "$HOME/.local/share/pcmanfm" ];
    desktops = [ "$HOME/.local/share/applications/pcmanfm*.desktop" ];
  }
  {
    name = "catfish";
    # Catfish é utilitário de busca integrado ao Thunar e XFCE4
    enabled =
      (config.system.programs.file-manager.thunar.enable or false)
      || (config.desktop.environments.xfce4.enable or false);
    configs = [ "$HOME/.config/catfish" ];
    caches = [ "$HOME/.cache/catfish" ];
    data = [ "$HOME/.local/share/catfish" ];
    desktops = [ "$HOME/.local/share/applications/org.xfce.Catfish*.desktop" ];
  }

  # --- Comunicação / Chat ---
  {
    name = "discord";
    enabled = config.system.programs.chat.discord.enable or false;
    configs = [
      "$HOME/.config/discord"
      "$HOME/.config/BetterDiscord"
      "$HOME/.config/Vencord"
    ];
    caches = [ "$HOME/.cache/discord" ];
    data = [ "$HOME/.local/share/discord" ];
    desktops = [ "$HOME/.local/share/applications/*discord*.desktop" ];
  }

  # --- Editores ---
  {
    name = "vscode";
    enabled = config.system.programs.editors.vscode.enable or false;
    configs = [ "$HOME/.config/Code" ];
    caches = [ "$HOME/.cache/vscode-cpptools" ];
    data = [ "$HOME/.local/share/Code" ];
    desktops = [ "$HOME/.local/share/applications/code*.desktop" ];
  }
  {
    name = "micro";
    enabled = config.system.programs.editors.micro.enable or false;
    configs = [ "$HOME/.config/micro" ];
    caches = [ ];
    data = [ "$HOME/.local/share/micro" ];
    desktops = [ ];
  }
  {
    name = "neovim";
    enabled = config.system.programs.editors.neovim.enable or false;
    configs = [ "$HOME/.config/nvim" ];
    caches = [ "$HOME/.cache/nvim" ];
    data = [
      "$HOME/.local/share/nvim"
      "$HOME/.local/state/nvim"
    ];
    desktops = [ "$HOME/.local/share/applications/nvim*.desktop" ];
  }

  # --- Terminais ---
  {
    name = "alacritty";
    enabled =
      (config.system.programs.terminal.enable or false)
      && (config.system.programs.terminal.default == "alacritty");
    configs = [ "$HOME/.config/alacritty" ];
    caches = [ ];
    data = [ ];
    desktops = [ "$HOME/.local/share/applications/Alacritty.desktop" ];
  }
  {
    name = "kitty";
    enabled =
      (config.system.programs.terminal.enable or false)
      && (config.system.programs.terminal.default == "kitty");
    configs = [ "$HOME/.config/kitty" ];
    caches = [ "$HOME/.cache/kitty" ];
    data = [ "$HOME/.local/share/kitty" ];
    desktops = [ "$HOME/.local/share/applications/kitty.desktop" ];
  }
  {
    name = "wezterm";
    enabled =
      (config.system.programs.terminal.enable or false)
      && (config.system.programs.terminal.default == "wezterm");
    configs = [ "$HOME/.config/wezterm" ];
    caches = [ ];
    data = [ ];
    desktops = [ "$HOME/.local/share/applications/org.wezfurlong.wezterm.desktop" ];
  }
  {
    name = "ghostty";
    enabled =
      (config.system.programs.terminal.enable or false)
      && (config.system.programs.terminal.default == "ghostty");
    configs = [ "$HOME/.config/ghostty" ];
    caches = [ ];
    data = [ ];
    desktops = [ "$HOME/.local/share/applications/com.mitchellh.ghostty.desktop" ];
  }

  # --- Navegadores ---
  {
    name = "thorium";
    enabled = config.system.programs.browsers.thorium.enable or false;
    configs = [ "$HOME/.config/thorium" ];
    caches = [ "$HOME/.cache/thorium" ];
    data = [ ];
    desktops = [ "$HOME/.local/share/applications/thorium*.desktop" ];
  }
  {
    name = "brave";
    enabled = config.system.programs.browsers.brave.enable or false;
    configs = [ "$HOME/.config/BraveSoftware" ];
    caches = [ "$HOME/.cache/BraveSoftware" ];
    data = [ ];
    desktops = [ "$HOME/.local/share/applications/brave-browser*.desktop" ];
  }
  {
    name = "google-chrome";
    enabled = config.system.programs.browsers.google-chrome.enable or false;
    configs = [ "$HOME/.config/google-chrome" ];
    caches = [ "$HOME/.cache/google-chrome" ];
    data = [ ];
    desktops = [ "$HOME/.local/share/applications/google-chrome*.desktop" ];
  }

  # --- Ferramentas Gráficas ---
  {
    name = "flameshot";
    enabled = config.system.programs.tools.flameshot.enable or false;
    configs = [ "$HOME/.config/flameshot" ];
    caches = [ ];
    data = [ ];
    desktops = [ "$HOME/.local/share/applications/org.flameshot.Flameshot.desktop" ];
  }
  {
    name = "heynote";
    enabled = config.system.programs.tools.heynote.enable or false;
    configs = [ "$HOME/.config/Heynote" ];
    caches = [ ];
    data = [ ];
    desktops = [ "$HOME/.local/share/applications/heynote.desktop" ];
  }
  {
    name = "obs-studio";
    enabled = config.system.programs.tools.obs-studio.enable or false;
    configs = [ "$HOME/.config/obs-studio" ];
    caches = [ ];
    data = [ ];
    desktops = [ "$HOME/.local/share/applications/com.obsproject.Studio.desktop" ];
  }

  # --- Multimídia ---
  {
    name = "vlc";
    enabled = config.system.programs.multimedia.vlc.enable or false;
    configs = [ "$HOME/.config/vlc" ];
    caches = [ "$HOME/.cache/vlc" ];
    data = [ "$HOME/.local/share/vlc" ];
    desktops = [ "$HOME/.local/share/applications/vlc.desktop" ];
  }
  {
    name = "gimp";
    enabled = config.system.programs.multimedia.gimp.enable or false;
    configs = [ "$HOME/.config/GIMP" ];
    caches = [ "$HOME/.cache/gimp" ];
    data = [ "$HOME/.local/share/GIMP" ];
    desktops = [ "$HOME/.local/share/applications/gimp*.desktop" ];
  }
  {
    name = "inkscape";
    enabled = config.system.programs.multimedia.inkscape.enable or false;
    configs = [ "$HOME/.config/inkscape" ];
    caches = [ "$HOME/.cache/inkscape" ];
    data = [ ];
    desktops = [ "$HOME/.local/share/applications/org.inkscape.Inkscape.desktop" ];
  }

  # --- Documentos ---
  {
    name = "zathura";
    enabled = config.system.programs.documents.zathura.enable or false;
    configs = [ "$HOME/.config/zathura" ];
    caches = [ ];
    data = [ "$HOME/.local/share/zathura" ];
    desktops = [ ];
  }
  {
    name = "libreoffice";
    enabled = config.system.programs.documents.libreoffice.enable or false;
    configs = [ "$HOME/.config/libreoffice" ];
    caches = [ ];
    data = [ ];
    desktops = [ ];
  }
]
