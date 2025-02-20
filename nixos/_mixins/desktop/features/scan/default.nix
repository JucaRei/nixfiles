{ config, desktop, lib, pkgs, username, ... }:
let
  inherit (lib) mkOption mkIf types optionals;
  scanningApp = if (desktop == "plasma") then pkgs.kdePackages.skanpage else pkgs.gnome.simple-scan;
  cfg = config.desktop.features.scan;
in
{
  options = {
    desktop.features.scan = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Whether enables scanner for desktop.";
      };
    };
  };
  config = mkIf cfg.enable {
    # Only enables auxilary scanning support/packages if
    # config.hardware.sane.enable is true; the master control
    # - https://wiki.nixos.org/wiki/Scanners
    environment = mkIf config.hardware.sane.enable { systemPackages = [ scanningApp ]; };

    hardware.sane = {
      # Hide duplicate backends
      #disabledDefaultBackends = [ "escl" ];
      enable = true;
      #extraBackends = with pkgs; [ hplipWithPlugin ];
      extraBackends = with pkgs; mkIf config.hardware.sane.enable [ sane-airscan ];
    };

    users.users.${username}.extraGroups = optionals config.hardware.sane.enable [ "scanner" ];
  };
}
