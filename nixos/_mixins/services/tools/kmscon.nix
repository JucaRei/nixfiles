{pkgs, ...}: {
  services = {
    # Use kmscon as the virtual console instead of gettys.
    # kmscon is a kms/dri-based userspace virtual terminal implementation.
    # It supports a richer feature set than the standard linux console VT,
    # including full unicode support, and when the video card supports drm should be much faster.
    kmscon = {
      enable = true;
      hwRender = true;
      fonts = [
        {
          name = "FiraCode Nerd Font Mono";
          package = pkgs.nerdfonts.override {fonts = ["FiraCode"];};
        }
      ];
      extraConfig = ''
        font-size=18
        xkb-layout=us
      '';
    };
  };
}
