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
      st
      pulseaudio-control
      gnome.nautilus
      gnome.sushi
      nautilus-open-any-terminal
    ];
  };

  xsession.windowManager.bspwm = {
    startupPrograms = [
      "pgrep -x sxhkd > /dev/null || sxhkd"
      "sleep 2s;polybar -q default"
      "xsetroot -cursor_name left_ptr"
      "dunst -config $HOME/.config/dunst/dunstrc"
      "$HOME/.screenlayout/vm.sh"
    ];
  };
  services = {
    sxhkd = {
      keybindings = {
        # Selected programs
        "super + Return" = "st"; # terminal emulator
        "super + @space" = "rofi -show drun -show-icons"; # program launcher
        "super + Escape" = "pkill -USR1 -x sxhkd"; # make sxhkd reload its configuration files
        "super + e" = "nemo";
        "super + b" = "thorium";
      };
    };
  };
}
