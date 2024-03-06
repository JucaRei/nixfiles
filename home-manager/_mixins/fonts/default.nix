# Fonts!
{ pkgs, config, ... }: {
  fonts = {
    fontconfig.enable = true;
  };

  home.packages = with pkgs.unstable; [
    # phospor-ttf
    # material-symbols-ttf
    noto-fonts
    noto-fonts-emoji
    # work-sans
    # joypixels
    hack-font
    cairo
    # ubuntu_font_family
    # apple-font

    material-design-icons
    (nerdfonts.override {
      fonts = [
        # "FiraCode"
        # "NerdFontsSymbolsOnly"
        # "UbuntuMono"
        # "Hack"
        # "DroidSansMono"
        # "JetBrainsMono"
      ];
    })
  ];
}
