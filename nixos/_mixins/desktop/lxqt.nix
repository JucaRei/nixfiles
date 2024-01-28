{ pkgs, config, lib, ... }: {
  services.xserver = {
    enable = true;
    desktopManager.lxqt = { enable = true; };
    displayManager = {
      sddm = { enable = true; };
      defaultSession = "lxqt";
      autoLogin = { enable = false; };
    };
    # Packages providing GDK-Pixbuf modules, for cache generation.
    # Enables GTK applications to load SVG icons.
    gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
    # Whether to update the DBus activation environment after launching the desktop manager.
    updateDbusEnvironment = true;
  };
  environment = {
    lxqt = {
      excludePackages = with pkgs.lxqt; [
        qtermwidget
        compton-conf # GUI configuration tool for compton (deprecated)
        # lximage-qt # the image viewer and screenshot tool for lxqt
        # lxqt-globalkeys # LXQt service for global keyboard shortcuts registration
        # lxqt-runner # tool used to launch programs quickly by typing their names
        # obconf-qt # the Qt port of obconf, the Openbox configuration tool
        # qterminal # a lightweight Qt-based terminal emulator
        # xscreensaver # a set of screensavers
      ];
    };
    systemPackages = with pkgs; [
      # alacritty
      # libsForQt5.konsole
      lxappearance
      lxqt.lxqt-themes
      lxqt.lxqt-archiver
      # lxqt.compton-conf
      # libsForQt5.networkmanager-qt
      # libnma
      # blueberry
      blueman
      networkmanagerapplet
    ];
  };
  xdg = {
    portal = {
      lxqt = lib.mkDefault {
        enable = true;
        styles = with pkgs; [
          pkgs.libsForQt5.qtstyleplugin-kvantum
          pkgs.breeze-qt5
          pkgs.qtcurve
        ];
      };
    };
  };
}
