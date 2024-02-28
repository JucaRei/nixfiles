{
  pkgs,
  lib,
  username,
  ...
}:
with lib.hm.gvariant; {
  home.packages = with pkgs;
    [kodi] ++ (with kodiPackages; [trakt youtube jellyfin]);

  # programs = {
  #     jellyfin = {
  #         enable = true;
  #         user = username;
  #     };
  #     jellyseerr.enable = true;
  #     jellyfin.openFirewall = true;
  # };

  # services.xserver.desktopManager.session = [{
  #   name = "kodi";
  #   start = ''
  #     ${pkgs.kodi}/bin/kodi --lircdev /var/run/lirc/lircd --standalone &
  #     waitPID=$!
  #   '';
  # }];
}
