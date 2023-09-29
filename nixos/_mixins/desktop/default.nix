{ desktop, lib, pkgs, ... }: {
  imports = [
    # ../apps/browser/chromium.nix
    # ../services/tools/cups.nix
    ../services/tools/flatpak.nix
    ../services/network/networkmanager.nix
    # ../services/printers/sane.nix
  ]
  ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix;

  boot = {
    # kernelParams = lib.mkDefault [ "quiet" ];
    plymouth.enable = lib.mkDefault true;
  };

  programs = {
    dconf.enable = true;
  };

  # Accept the joypixels license
  nixpkgs.config.joypixels.acceptLicense = true;

  # Disable xterm
  services.xserver = {
    excludePackages = [ pkgs.xterm ];
    desktopManager.xterm.enable = false;
  };
}
