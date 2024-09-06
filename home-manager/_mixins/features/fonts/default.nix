# Fonts!
{ pkgs, config, lib, isWorkstation, ... }:
let
  inherit (lib) mkOption mkIf types optional;
  cfg = config.features.fonts;
in
{
  options.features.fonts = {
    enable = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Whether enable default fonts for the system.
      '';
    };
    enableNerdFonts = mkOption {
      type = types.bool;
      default = isWorkstation;
      description = "Whether enable nerd fonts";
    };

  };
  config = mkIf cfg.enable {
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
        # apple-font
      ] ++ lib.optional cfg.enableNerdFonts [
        work-sans
        ubuntu_font_family
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
      fontconfig.enable = true;
    };
    home.sessionVariables = mkIf cfg.enableNerdFonts {
      LOG_ICONS = "true"; # Enable as nerdfonts is on.
    };
  };
}
