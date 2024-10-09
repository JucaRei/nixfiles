{ config, desktop, isInstall, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types optionals;
  cfg = config.desktop.features.printers;
in
{
  options = {
    desktop.features.flatpak-appcenter = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Whether enables printing for desktop.";
      };
    };
  };
  config = mkIf cfg.enable {
    # Only enables auxilary printing support/packages if
    # config.services.printing.enable is true; the master control
    # - https://wiki.nixos.org/wiki/Printing
    programs.system-config-printer = mkIf config.services.printing.enable {
      enable = if (desktop == "mate" || desktop == "hyprland") then true else false;
    };
    services = {
      printing = {
        enable = true;
        drivers =
          with pkgs;
          optionals config.services.printing.enable [
            gutenprint
            hplip
          ];
        webInterface = false;
      };
      system-config-printer.enable = config.services.printing.enable;
    };
  };
}
