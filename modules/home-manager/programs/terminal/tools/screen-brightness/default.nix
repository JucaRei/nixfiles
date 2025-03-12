{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.programs.terminal.tools.screen-brightness;
in
{
  options = {
    programs.terminal.tools = {
      screen-brightness = {
        enable = mkOption {
          type = bool;
          default = false;
          description = mdDoc "Enable's screen brightness.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [ pkgs.brillo ];
    };

    # Hardware: {decrease, increase} screen backlight - fn + {f4,f5}
    services.sxhkd.keybindings = mkIf (config.services.sxhkd.enable) {
      "@XF86MonBrightnessDown" = ''
        ${pkgs.brillo}/bin/brillo -Ll \
            | ${pkgs.xe}/bin/xe \
                -I '!!' \
                -j0 \
                ${pkgs.brillo}/bin/brillo \
                    -s !! \
                    -u 100000 \
                    -q \
                    -U 2
      '';
      "@XF86MonBrightnessUp" = ''
        ${pkgs.brillo}/bin/brillo -Ll \
            | ${pkgs.xe}/bin/xe \
                -I '!!' \
                -j0 \
                ${pkgs.brillo}/bin/brillo \
                    -s !! \
                    -u 100000 \
                    -q \
                    -A 2
      '';
    };
  };
}
