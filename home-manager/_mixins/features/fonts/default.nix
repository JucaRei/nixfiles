# Fonts!
{ pkgs, config, lib, isWorkstation, ... }:
let
  inherit (lib) mkOption mkIf types optionals;
  cfg = config.custom.features.fonts;

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
  options.custom.features.fonts = {
    enable = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Whether enable default fonts for the system.
      '';
    };
    # enableNerdFonts = mkOption {
    #   type = types.bool;
    #   default = isWorkstation;
    #   description = "Whether enable nerd fonts";
    # };

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
      ] ++ lib.optionals isWorkstation [
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

        font-search
      ];
    };

    fonts = {
      fontconfig.enable = true;
    };
    home.sessionVariables = mkIf isWorkstation {
      LOG_ICONS = "true"; # Enable as nerdfonts is on.
    };
  };
}
