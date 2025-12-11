{ config, lib, pkgs, notVM, ... }:
let
  inherit (lib) mkDefault mkIf;
  hasNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
  cfg = config.desktop.environment;
in
{
  config = {
    desktop = {
      display-manager = {
        chosen = "sddm";
        sddm = {
          sddm-theme = "abstractdark-sddm-theme";
        };
      };
      backend = "wayland";
    };

    environment = {
      plasma6.excludePackages = with pkgs.kdePackages; [
        elisa
        khelpcenter
        oxygen
      ];

      variables = mkIf (hasNvidia) {
        NVD_GPU = 1;
      };
    };

    programs = {
      kdeconnect = mkIf (notVM) {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };
    };

    services = {
      desktopManager.plasma6 = {
        enable = true;
        enableQt5Integration = true;

      };
    };

    qt = {
      enable = true;
      platformTheme = "kde";
      style = "kvantum";
    };
  };
}
