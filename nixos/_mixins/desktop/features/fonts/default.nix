{ config, isInstall, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.desktop.features.fonts;
in
{
  options = {
    desktop.features.fonts = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Enables defaults fonts for desktop.";
      };
    };
  };
  config = mkIf cfg.enable {
    # https://yildiz.dev/posts/packing-custom-fonts-for-nixos/
    fonts = {
      # Enable a basic set of fonts providing several font styles and families and reasonable coverage of Unicode.
      enableDefaultPackages = false;
      fontDir.enable = true;
      packages =
        with pkgs;
        [
          (nerdfonts.override {
            fonts = [
              "FiraCode"
              "NerdFontsSymbolsOnly"
            ];
          })
          font-search # show existent fonts
          merriweather
          fira
          font-awesome
          # liberation_ttf
          # noto-fonts-emoji
          # noto-fonts-monochrome-emoji
          # source-serif
          # symbola
          # work-sans
          lato
        ]
        ++ lib.optionals isInstall [
          # bebas-neue-2014-font
          # bebas-neue-pro-font
          # bebas-neue-rounded-font
          bebas-neue-semi-rounded-font
          # boycott-font
          # commodore-64-pixelized-font
          # digital-7-font
          # dirty-ego-font
          # fixedsys-core-font
          # fixedsys-excelsior-font
          # impact-label-font
          # mocha-mattari-font
          # poppins-font
          # spaceport-2006-font
          # ubuntu_font_family
          # unscii
          # zx-spectrum-7-font
        ];

      fontconfig = {
        antialias = true;
        # Enable 32-bit support if driSupport32Bit is true
        cache32Bit = lib.mkForce config.hardware.graphics.enable32Bit;
        defaultFonts = {
          serif = [
            # "Source Serif"
            # "Noto Color Emoji"
            "Merriweather"
          ];
          sansSerif = [
            "Lato"
            # "Work Sans"
            # "Fira Sans"
            # "Noto Color Emoji"
          ];
          monospace = [
            "Merriweather"
            "FiraCode Nerd Font Mono"
            # "Font Awesome 6 Free"
            # "Font Awesome 6 Brands"
            # "Symbola"
            # "Noto Emoji"
          ];
          emoji = [
            "Noto Color Emoji"
          ];
        };
        enable = true;
        hinting = {
          autohint = false;
          enable = true;
          style = "slight";
        };
        subpixel = {
          rgba = "rgb";
          lcdfilter = "light";
        };
      };
    };
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "mocha_mattari"
    ];
  };
}
