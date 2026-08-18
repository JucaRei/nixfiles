{ desktop, lib, config, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.nixos.services.flatpak-appcenter;
in
{
  options = {
    nixos.services.flatpak-appcenter = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Enables Flatpak Appcenter.";
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      flatpak = {
        enable = true;
        # By default nix-flatpak will add the flathub remote;
        # Therefore Appcenter is only added when the desktop is Pantheon
        remotes = lib.mkIf (desktop == "pantheon") [
          {
            name = "appcenter";
            location = "https://flatpak.elementary.io/repo.flatpakrepo";
          }
        ];
        update.auto = {
          enable = true;
          onCalendar = "weekly";
        };
      };
    };
  };
}
