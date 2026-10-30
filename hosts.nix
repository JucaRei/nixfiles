# hosts.nix — Fonte declarativa única para todos os hosts e imagens
{
  home = {
    fedora = {
      desktop = "bspwm";
    };
    anubis = {
      desktop = "mangowm";
      waylandShell = "noctalia";
    };
    nitro = {
      desktop = "bspwm";
      # Intel UHD 630 gerencia o display; nixGLNvidia quebrado no nixpkgs 26.05
      nixGLType = "intel";
    };
    virtual = {
      desktop = "bspwm";
      isVM = true;
    };
    virtualvm = {
      desktop = "dwm";
      stateVersion = "24.05";
      isVM = true;
    };
    anubisvm = {
      desktop = "bspwm";
      isVM = true;
    };
  };

  nixos = {
    rocinante = {
      desktop = "dwm";
      stateVersion = "22.11";
    };
    rocinante-vm = {
      desktop = "bspwm";
      stateVersion = "24.11";
      isVM = true;
    };
    rocinante-hyperv = {
      desktop = "bspwm";
      stateVersion = "24.11";
      isVM = true;
    };
    iso-rocinante = {
      desktop = "xfce4";
      stateVersion = "24.11";
      isISO = true;
    };
  };

  isos = [
    "xfce4"
    "gnome"
    "mate"
    "pantheon"
    "bspwm"
    "dwm"
    null # iso-console
  ];
}
