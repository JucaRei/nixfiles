{ isInstall, lib, pkgs, config, ... }:
let
  inherit (pkgs.stdenv) isDarwin;
  inherit (lib) mkIf mkOption types optionals;
  isOtherOS = if builtins.isString (builtins.getEnv "__NIXOS_SET_ENVIRONMENT_DONE") then false else true;
  cfg = config.features.fonts;
  systems = if (isDarwin == true || isOtherOS == true) then true else false;

in
{
  options.features.fonts = {
    enable = mkOption {
      default = systems;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://yildiz.dev/posts/packing-custom-fonts-for-nixos/
    home = {
      packages = with pkgs; [
        (nerdfonts.override {
          fonts = [
            "FiraCode"
            "NerdFontsSymbolsOnly"
          ];
        })
        # font-awesome
        # liberation_ttf
        # noto-fonts-emoji
        # noto-fonts-monochrome-emoji
        # source-serif
        # symbola
        # work-sans
      ]
      ++ optionals isInstall [
        # bebas-neue-2014-font
        # bebas-neue-pro-font
        # bebas-neue-rounded-font
        # bebas-neue-semi-rounded-font
        # boycott-font
        # commodore-64-pixelized-font
        # digital-7-font
        # dirty-ego-font
        # fixedsys-core-font
        # fixedsys-excelsior-font
        # impact-label-font
        # mocha-mattari-font
        # poppins-font
        # ubuntu_font_family
      ]
      ;
    };
    # fonts.fontconfig = {
    #   enable = true;
    #   defaultFonts = {
    #     serif = [
    #       # "Source Serif"
    #       # "Noto Color Emoji"
    #       "Merriweather"
    #     ];
    #     sansSerif = [
    #       "Lato"
    #       # "Work Sans"
    #       # "Fira Sans"
    #       # "Noto Color Emoji"
    #     ];
    #     monospace = [
    #       "Merriweather"
    #       "FiraCode Nerd Font Mono"
    #       # "Font Awesome 6 Free"
    #       # "Font Awesome 6 Brands"
    #       # "Symbola"
    #       # "Noto Emoji"
    #     ];
    #     emoji = [
    #       "Noto Color Emoji"
    #     ];
    #   };
    # };
  };
}
