_: {
  imports = [
    ./dunst.nix
    ./picom.nix
    ./xresources.nix
    # ./polybar.nix
    ./polybar-test.nix
    ./rofi.nix
  ];

  home.file.".owm-key" = {
    text = ''
      3901194171bca9e5e3236048e50eb1a5
    '';
  };
}
