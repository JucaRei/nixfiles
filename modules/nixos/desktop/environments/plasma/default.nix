{ config, lib, pkgs, notVM, ... }:
let
  inherit (lib) mkDefault mkIf;
  hasNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
in
{
  config = mkDefault {
    desktop = {
      display-managers = {
        name = "sddm";
        sddm = {
          sddm-theme = "abstractdark-sddm-theme";
          wayland-session = true;
        };
      };
      display-server = {
        backend = "wayland";
      };
    };

    environment = {
      plasma6.excludePackages = with pkgs; [
        elisa
        khelpcenter
        oxygen
      ];

      variables = mkIf (hasNvidia) {
        NVD_GPU = 1;
      };
    };

    programs = {
      kdeconnect = {
        enable = mkIf (notVM) true;
        package = pkgs.gnomeExtensions.gsconnect;
      };
    };

    services = {
      displayManager = {
        defaultSession = "plasma"; #plasmax11
      };
      desktopManager = {
        plasma6 = {
          enable = true;
          enableQt5Integration = true;
        };
      };
    };

    qt.platformTheme = "kde";
  };
}
