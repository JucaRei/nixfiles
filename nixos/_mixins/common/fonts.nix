{ pkgs, lib, ... }:
let
  lotsOfFonts = true;
in
{
  fonts = {
    fontDir.enable = true;
    ## nix 23.05
    fonts = (with pkgs; [ 
    # packages = (with pkgs; [
      # renamed on 23.11 
      (nerdfonts.override { fonts = [ "FiraCode" "SourceCodePro" "UbuntuMono" ]; })
      fira
      fira-go
      joypixels
      # liberation_ttf
      gyre-fonts # TrueType substitutes for standard PostScript fonts
      noto-fonts-emoji # emoji
      source-serif
      ubuntu_font_family
      work-sans
      # siji # https://github.com/stark/siji
      source-code-pro
      terminus_font
      source-sans-pro
      roboto
      material-design-icons
      font-awesome
      inter
      maple-mono
      maple-mono-NF
      maple-mono-SC-NF
      meslo-lg
      cozette
    ] ++ lib.optionals lotsOfFonts [
      # Japanese
      ipafont # display jap symbols like シートベルツ in polybar
      kochi-substitute

      # Code/monospace and nsymbol fonts
      fira-code
      fira-code-symbols
      mplus-outline-fonts.osdnRelease
      dejavu_fonts
      iosevka-bin
    ]);

    ## Enable a basic set of fonts providing several font styles and families and reasonable coverage of Unicode.
    enableDefaultFonts = false;
    # enableDefaultPackages = false; # renamed on 23.11 

    fontconfig = {
      antialias = true;
      allowBitmaps = true;
      cache32Bit = true;
      useEmbeddedBitmaps = true;
      defaultFonts = {
        serif = [ "Source Serif" ];
        sansSerif = [ "Work Sans" "Fira Sans" "FiraGO" ];
        monospace = [ "FiraCode Nerd Font Mono" "SauceCodePro Nerd Font Mono" ];
        emoji = [ "Joypixels" "Noto Color Emoji" ];
      };
      enable = true;
      hinting = {
        autohint = false;
        enable = true;
        style = "hintslight";
        # style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "light";
      };
    };

    # # Lucida -> iosevka as no free Lucida font available and it's used widely
    fontconfig.localConf = lib.mkIf lotsOfFonts ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <match target="pattern">
          <test name="family" qual="any"><string>Lucida</string></test>
          <edit name="family" mode="assign">
            <string>iosevka</string>
          </edit>
        </match>
      </fontconfig>
    '';
  };
}
