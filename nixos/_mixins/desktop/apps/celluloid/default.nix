{ desktop, isInstall, lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.desktop.apps.celluloid;
in
{
  options = {
    desktop.apps.celluloid = {
      enable = mkOption {
        type = types.bool;
        default = isInstall && (desktop == "mate" || desktop == "gnome");
        description = "Enables celluloid.";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ celluloid ];

    programs = {
      dconf.profiles.user.databases = [
        {
          settings = with lib.gvariant; {
            "io/github/celluloid-player/celluloid" =
              lib.optionalAttrs (desktop != "gnome") { csd-enable = false; }
              // {
                dark-theme-enable = true;
              };
          };
        }
      ];
    };
  };
}
