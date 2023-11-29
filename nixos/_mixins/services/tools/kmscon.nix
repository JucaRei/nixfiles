{ pkgs, ... }: {
  services = {
    kmscon = {
      enable = true;
      hwRender = true;
      fonts = [{
        name = "FiraCode Nerd Font Mono";
        package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
      }];
      extraConfig = ''
        font-size=16
        xkb-layout=us
      '';
    };
  };
}
