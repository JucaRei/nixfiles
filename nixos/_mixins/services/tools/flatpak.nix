{ pkgs, ... }: {
  services.flatpak = {
    enable = true;
    systemd.services.configure-flathub-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
    update = {
      auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };
  };
  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };
  };
}
