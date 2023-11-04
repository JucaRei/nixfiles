{ pkgs, config, lib, ... }: {
  services.xserver = {
    enable = true;
    desktopManager.lxqt = {
      enable = true;
    };
    displayManager = {
      sddm = {
        enable = true;
      };
      defaultSession = "lxqt";
      autoLogin = {
        enable = false;
      };
    };
  };
  environment = {
    lxqt = {
      excludePackages = with pkgs.lxqt; [
        qterminal
        qtermwidget
      ];
    };
    systemPackages = with pkgs; [
      alacritty
      lxappearance
      lxqt.lxqt-themes
      lxqt.compton-conf
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
