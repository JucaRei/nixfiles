{ pkgs, lib, ... }: {
  users.users.kodi.isNormalUser = true;
  services = {
    # disable greetd, as cage starts directly
    greetd.enable = lib.mkForce false;

    # cage is compositor and "login manager" that starts a single program: Kodi
    cage = {
      enable = true;
      user = "kodi";
      # program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
      program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
      environment = {
        # TODO does this suppport layout switching? try out
        # XKB_DEFAULT_LAYOUT = "br,en";
        XKB_DEFAULT_LAYOUT = "br";
        # XKB_DEFAULT_VARIANT = "abnt2,nodeadkeys";
        XKB_DEFAULT_VARIANT = "abnt2";
        XKB_DEFAULT_OPTIONS = "grp:ctrls_toggle";
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 8080 ]; # for web interface / remote control
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  environment.systemPackages = with pkgs; [
    # for manual usage if needed
    pkgs.cage
    pkgs.kodi-wayland
  ];
}
