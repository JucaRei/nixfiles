# Fonts!
{ pkgs, config, lib, ... }: {
  home = {
    packages = with pkgs.unstable; [

      # phospor-ttf
      # material-symbols-ttf
      # noto-fonts
      # noto-fonts-emoji
      # work-sans
      # joypixels
      hack-font
      cairo
      ubuntu_font_family
      work-sans
      # ubuntu_font_family
      # apple-font

      material-design-icons
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "RobotoMono"
          "NerdFontsSymbolsOnly"
          # "UbuntuMono"
          # "Hack"
          # "DroidSansMono"
          # "JetBrainsMono"
        ];
      })
    ];
  };

  fonts = {
    fontconfig.enable = lib.mkForce true;
  };
  home.sessionVariables = {
    LOG_ICONS = "true"; # Enable as nerdfonts is on.
  };
}
