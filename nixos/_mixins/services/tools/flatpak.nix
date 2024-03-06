{pkgs, ...}: {
  config = {
    services.flatpak.enable = true;
    systemd.services.configure-flathub-repo = {
      wantedBy = ["multi-user.target"];
      path = [pkgs.flatpak];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
    environment = {sessionVariables = {XDG_DATA_DIRS = ["/usr/share"];};};
  };
}
