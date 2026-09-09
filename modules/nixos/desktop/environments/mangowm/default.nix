{ pkgs, inputs, ... }:
let
  mangoPkg =
    if (inputs ? mangowm && inputs.mangowm ? packages && inputs.mangowm.packages ? ${pkgs.stdenv.hostPlatform.system}) then
      inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.mango
    else
      pkgs.emptyDirectory;
in
{
  config = {
    desktop = {
      display-servers.backend = "wayland";
      display-managers.name = "regreet";
    };

    environment = {
      systemPackages = [ mangoPkg ];
      homeBinInPath = true;
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      };
    };

    security.pam.services.hyprlock = { };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
