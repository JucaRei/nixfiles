{ config, pkgs, lib, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.fonts;
in
{
  imports = [ (lib.snowfall.fs.get-file "modules/shared/system/fonts/default.nix") ];

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        font-manager
        fontpreview
        smile
      ];
    };

    fonts = {
      packages = with pkgs; [
        lexend
        nerd-fonts.iosevka
      ]
      ++ cfg.fonts;

      enableDefaultPackages = true;

      fontconfig = {
        enable = true;
        # enableSubpixel = true;
        antialias = true;
        hinting.enable = true;
      };

      fontDir = {
        enable = true;
        decompressFonts = false;
        # path = "/usr/share/fonts";
      };

    };

    systemd = {
      tmpfiles.rules = [
        "d /usr/share/fonts 0755 root root"
      ];
    };
  };
}
