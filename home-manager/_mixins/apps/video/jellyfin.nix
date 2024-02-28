{
  pkgs,
  lib,
  ...
}:
with lib.hm.gvariant; {
  home.packages = with pkgs; [jellyfin jellyfin-web jellyfin-mpv-shim];

  services.jellyfin = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  # for hardware acceleration
  systemd.services.jellyfin.serviceConfig = {
    DeviceAllow = lib.mkForce ["/dev/dri/renderD128"];
  };
}
