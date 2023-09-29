_: {
  security.doas = {
    enable = true;
    extraConfig = ''
      permit nopass :wheel
    '';
    #wheelNeedsPassword = false;
  };
}
