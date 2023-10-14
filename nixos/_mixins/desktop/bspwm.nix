{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      rofi
      rofi-calc
      libusb1 # for Xbox controller
      xorg.xwininfo # Provides a cursor to click and learn about windows

      # File and system utilities
      inotify-tools # inotifywait, inotifywatch - For file system events
      i3lock-fancy-rapid
      libnotify
      ledger-live-desktop
      playerctl # Control media players from command line
      pinentry-curses
      pcmanfm # Our file browser
      sqlite
      xdg-utils

      # Other utilities
      yad # I use yad-calendar with polybar
      xdotool

      # PDF viewer
      zathura

      # Screenshot and recording tools
      flameshot
      simplescreenrecorder
    ];
  };
}
