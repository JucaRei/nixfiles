# Fonts!
{ pkgs, config, ... }: {
  fonts = { fontconfig.enable = true; };

  home.packages = with pkgs; [
    # phospor-ttf
    # material-symbols-ttf
    noto-fonts
    noto-fonts-emoji
    fira-code
    fira-code-symbols
    # work-sans
    # joypixels
    hack-font
    cairo
    ubuntu_font_family
    # apple-font

    material-design-icons
    # (nerdfonts.override {
    # fonts = [
    # "FiraCode"
    # "UbuntuMono"
    # "Hack"
    # "DroidSansMono"
    # "JetBrainsMono"
    # ];
    # })
  ];
}
