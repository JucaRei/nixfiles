{ lib, config, ... }:
with lib;
let
  cfg = config.services.plymouth;
in
{
  options.services.plymouth = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable plymouth animation for boot start.
      '';
    };
  };
  config = mkIf cfg.enable {
    boot =
      {
        # initrd = {
        #   systemd.enable = true;
        #   verbose = false;
        # };
        kernelParams = [
          "quiet"
          "splash"
          "rd.systemd.show_status=false"
          "rd.udev.log_level=3"
          "udev.log_priority=3"
        ];
        plymouth = rec {
          enable = true;
          # black_hud circle_hud cross_hud square_hud
          # circuit connect cuts_alt seal_2 seal_3

          # logo = "${inputs.nixos-artwork}/wallpapers/nix-wallpaper-watersplash.png";
          theme = "deus_ex";
          themePackages = with pkgs; [
            (
              # pkgs.catppuccin-plymouth
              adi1090x-plymouth-themes.override {
                selected_themes = [ theme ];
              }
            )
          ];
        };
      };
    systemd.watchdog.rebootTime = "0";
  };
}
