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
    samba = {
      enable = true;
      extraConfig = ''
        client min protocol = NT1
      '';
    };
    gvfs.enable = true;

    clight = {
      enable = true;
      settings = {
        verbose = true;
        backlight.disabled = true;
        dpms.timeouts = [ 900 300 ];
        dimmer.timeouts = [ 870 270 ];
        gamma.long_transitions = true;
        screen.disabled = true;
      };
    };

    # needed for GNOME services outside of GNOME Desktop
    dbus.packages = [ pkgs.gcr ];

    udev = {
      packages = with pkgs; [ gnome.gnome-settings-daemon ];
      extraRules = ''
        # add my android device to adbusers
        SUBSYSTEM=="usb", ATTR{idVendor}=="22d9", MODE="0666", GROUP="adbusers"
      '';
    };
  };
  # };
  hardware = {
    # smooth backlight control
    brillo.enable = true;
  };

  environment = {
    systemPackages = with pkgs;[
      # hacked-cursor
      desktop-file-utils
    ];
  };

  security = {
    # allow wayland lockers to unlock the screen
    pam.services.swaylock.text = "auth include login";

    # userland niceness
    rtkit.enable = true;
  };
}
