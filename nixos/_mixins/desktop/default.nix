{ desktop, lib, pkgs, hostname, ... }:
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
    # ../services/tools/flatpak.nix # Use the home-manager version
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
    plymouth.enable = if hostname != "rasp3" then lib.mkDefault true else false;
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
      enable = if hostname != "rasp3" then true else false;
      package = pkgs.unstable.samba4Full;
      extraConfig = ''
        client min protocol = NT1
      '';
    };
    gvfs = {
      package = pkgs.unstable.gvfs;
      enable = true;
    };

    clight = {
      enable = if hostname != "rasp3" then true else false;
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
    # dbus.packages = if hostname != "rasp3" then [ pkgs.gcr ] else "";

    udev =
      if hostname != "rasp3" then {
        packages = with pkgs; [ gnome.gnome-settings-daemon ];
        extraRules = ''
          # add my android device to adbusers
          SUBSYSTEM=="usb", ATTR{idVendor}=="22d9", MODE="0666", GROUP="adbusers"
        '';
      } else "";
  };
  # };
  hardware = {
    # smooth backlight control
    brillo.enable = if hostname != "rasp3" then true else false;
  };

  environment = {
    systemPackages = with pkgs;[
      # hacked-cursor
      desktop-file-utils
    ];
  };

  security = {
    # userland niceness
    rtkit.enable = true;
  };
}
