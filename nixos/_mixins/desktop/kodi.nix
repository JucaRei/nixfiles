{ pkgs, lib, ... }: {
  users.users.kodi.isNormalUser = true;
  services = {
    # disable greetd, as cage starts directly
    # greetd.enable = lib.mkForce false;
    xserver = {
      enable = true;
      desktopManager.kodi.enable = true;
      displayManager = {
        autoLogin.enable = true;
        displayManager.autoLogin.user = "kodi";

        # This may be needed to force Lightdm into 'autologin' mode.
        # Setting an integer for the amount of time lightdm will wait
        # between attempts to try to autologin again.
        displayManager.lightdm.autoLogin.timeout = 3;
      };
    };
    # Define a user account
    users.extraUsers.kodi.isNormalUser = true;

    # cage is compositor and "login manager" that starts a single program: Kodi
    # cage = {
    #   enable = true;
    #   user = "kodi";
    #   program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
    #   environment = {
    #     # TODO does this suppport layout switching? try out
    #     # XKB_DEFAULT_LAYOUT = "br,en";
    #     XKB_DEFAULT_LAYOUT = "br";
    #     # XKB_DEFAULT_VARIANT = "abnt2,nodeadkeys";
    #     XKB_DEFAULT_VARIANT = "abnt2";
    #     XKB_DEFAULT_OPTIONS = "grp:ctrls_toggle";
    #   };
    # };
  };
  networking.firewall = {
    allowedTCPPorts = [ 8080 ]; # for web interface / remote control
    allowedUDPPorts = [ 8080 ];
  };
  # xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  # environment.systemPackages = with pkgs; [
  #   # for manual usage if needed
  #   pkgs.cage
  #   pkgs.kodi-wayland
  # ];
  nixpkgs.config.kodi.enableAdvancedLauncher = true;
}
