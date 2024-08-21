{ isInstall, lib, pkgs, ... }:
let
  # inherit (pkgs.stdenv) isDarwin;
  # isOtherOS = if builtins.isString (builtins.getEnv "__NIXOS_SET_ENVIRONMENT_DONE") then false else true;
  font-search = pkgs.writeShellScriptBin "font-search" ''
    fc-list \
        | grep -ioE ": [^:]*$1[^:]+:" \
        | sed -E 's/(^: |:)//g' \
        | tr , \\n \
        | sort \
        | uniq
  '';
in
{
  options.modules.fonts = {
    # enable = lib.mkEnableOption "Enable Fonts" // {
    #   default = false;
    #   # type = lib.types.bool;
    # };
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };
  };

  config = {
    # https://yildiz.dev/posts/packing-custom-fonts-for-nixos/
    home = {
      packages =
        with pkgs;
        [
          (nerdfonts.override {
            fonts = [
              "FiraCode"
              "NerdFontsSymbolsOnly"
            ];
          })
          fira
          liberation_ttf
          noto-fonts-emoji
          source-serif
          symbola
          work-sans
          font-search
        ]
        ++ lib.optionals isInstall [
          bebas-neue-2014-font
          bebas-neue-pro-font
          bebas-neue-rounded-font
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
          twitter-color-emoji
          # ubuntu_font_family
          # unscii
          # zx-spectrum-7-font
        ];
    };

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = lib.mkDefault [ "Source Serif" ];
        sansSerif = lib.mkDefault [
          "Work Sans"
          "Fira Sans"
        ];
        monospace = lib.mkDefault [
          "FiraCode Nerd Font Mono"
          "Symbols Nerd Font Mono"
        ];
        emoji = lib.mkDefault [
          "Noto Color Emoji"
          "Twitter Color Emoji"
        ];
      };
    };
  };
}
