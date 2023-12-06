{ pkgs, ... }: {
  imports = [
    ./dunst.nix
    ./picom.nix
    ./xresources.nix
    # ./polybar.nix
    ./polybar-test.nix
    ./rofi.nix
  ];

  home = {
    file.".owm-key" = {
      text = ''
        3901194171bca9e5e3236048e50eb1a5
      '';
    };
    packages = with pkgs; [
      pulseaudio-control
      nautilus
      nautilus-open-any-terminal
      nautilus-python
    ];
  };

  xsession.windowManager.bspwm = {
    startupPrograms = [
      "pgrep -x sxhkd > /dev/null || sxhkd"
      "sleep 2s;polybar -q main"
      "xsetroot -cursor_name left_ptr"
      "dunst -config $HOME/.config/dunst/dunstrc"
    ];
  };
}
