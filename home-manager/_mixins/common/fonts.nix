# Fonts!
{ pkgs, config, ... }:

{
  fonts = {
    fontconfig.enable = true;
  };

  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    fira-code
    fira-code-symbols
    work-sans
    joypixels
    ubuntu_font_family

    material-design-icons
    (nerdfonts.override { fonts = [ "FiraCode" "UbuntuMono" "DroidSansMono" ]; })
  ];
}

