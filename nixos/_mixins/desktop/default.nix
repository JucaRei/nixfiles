{ desktop, lib, pkgs, ... }:
# with lib;
# with builtins;
# let
#   xorg = (elem "xorg" config.sys.hardware.graphics.desktopProtocols);
#   wayland = (elem "wayland" config.sys.hardware.graphics.desktopProtocols);
#   desktopMode = xorg || wayland;
# in
{
  # config = mkIf desktopMode {
  imports = [
    # ../apps/browser/chromium.nix
    # ../services/tools/cups.nix
    ../services/tools/flatpak.nix
    ../services/network/networkmanager.nix
    # ../services/printers/sane.nix
  ]
  ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix;

  # Fix issue with java applications and tiling window managers.
  environment.sessionVariables = {
    "_JAVA_AWT_WM_NONREPARENTING" = "1";
  };

  boot = {
    # kernelParams = lib.mkDefault [ "quiet" ];
    plymouth.enable = lib.mkDefault true;
  };

  programs = {
    dconf.enable = true;
  };

  # Accept the joypixels license
  nixpkgs.config.joypixels.acceptLicense = true;

  services = {
    # Disable xterm
    xserver = {
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
    };
    gvfs.enable = true;
  };
  # };
  hardware = {
    # smooth backlight control
    brillo.enable = true;
  };

  environment = {
    systemPackages = with pkgs;[
      hacked-cursor
    ];
  };
}
