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
    hack-font
    ubuntu_font_family
    font-awesome

    material-design-icons
    (nerdfonts.override { fonts = [ "FiraCode" "UbuntuMono" "Hack" "DroidSansMono" "JetBrainsMono" ]; })
  ];
}
