{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.system.services.fcitx5;

  fcitx5Configtool = pkgs.qt6Packages.fcitx5-configtool or pkgs.kdePackages.fcitx5-configtool or null;
  fcitx5ChineseAddons = pkgs.qt6Packages.fcitx5-chinese-addons or null;

  fcitx5Addons =
    with pkgs;
    [
      fcitx5-gtk
      fcitx5-mozc # Motor Japonês (Google Mozc - Romaji para Hiragana/Katakana/Kanji)
      fcitx5-hangul # Motor Coreano
    ]
    ++ lib.optional (fcitx5ChineseAddons != null) fcitx5ChineseAddons
    ++ lib.optional (fcitx5Configtool != null) fcitx5Configtool;
in
{
  options.system.services.fcitx5 = {
    enable = mkEnableOption "Fcitx5 Input Method Framework com suporte a Japonês (Mozc) e CJK";
  };

  config = mkIf cfg.enable {
    # Habilitar Fcitx5 no Home Manager
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = (config.desktop.display-servers.backend or "") == "wayland";
        addons = fcitx5Addons;
      };
    };

    # Variáveis de ambiente essenciais para GTK, Qt, Java e jogos
    home.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      SDL_IM_MODULE = "fcitx";
      GLFW_IM_MODULE = "ibus";
    };

    # Pacotes de fontes essenciais (fcitx5-config-qt já é exportado no PATH pelo fcitx5-with-addons)
    home.packages = [
      pkgs.noto-fonts-cjk-sans
      pkgs.ipafont
    ];

    # Configuração declarativa de perfil (layout padrão + Mozc)
    xdg.configFile."fcitx5/profile".text = ''
      [Groups/0]
      Name=Default
      Default Layout=us
      DefaultIM=keyboard-us

      [Groups/0/Items/0]
      Name=keyboard-us
      Layout=

      [Groups/0/Items/1]
      Name=mozc
      Layout=

      [GroupOrder]
      0=Default
    '';

    # Configuração declarativa global (Atalhos de ativação: Control+Space, Zenkaku_Hankaku, Super+Space)
    xdg.configFile."fcitx5/config".text = ''
      [Hotkey]
      EnumerateForwardKeys=
      EnumerateBackwardKeys=
      EnumerateSkipFirst=False

      [Hotkey/TriggerKeys]
      0=Control+space
      1=Zenkaku_Hankaku
      2=Hangul

      [Hotkey/AltTriggerKeys]
      0=Shift_L

      [Hotkey/EnumerateGroupForwardKeys]
      0=Super+space
    '';
  };
}
