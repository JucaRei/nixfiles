{ pkgs, ... }: {
  # USB auto-mount
  services = {
    gvfs = {
      enable = true;
      package = pkgs.gnome.gvfs;
    };
    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
    devmon.enable = true;
  };
}
