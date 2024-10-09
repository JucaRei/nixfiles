{ desktop, lib, config, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.desktop.features.flatpak-appcenter;
in
{
  options = {
    desktop.features.flatpak-appcenter = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Enables Flatpak Appcenter.";
      };
    };
  };

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
}
