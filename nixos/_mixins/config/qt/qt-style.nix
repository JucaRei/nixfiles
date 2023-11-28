{ lib, pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      # libsForQt5.qtstyleplugin-kvantum
      # libsForQt5.qt5ct
      qgnomeplatform-qt6
    ];

    # Required to coerce dark theme that works with Yaru
    # TODO: Set this in the user-session
    variables = lib.mkForce {
      QT_QPA_PLATFORMTHEME = "gnome";
      QT_STYLE_OVERRIDE = "Adwaita-Dark";
    };
  };

  qt = {
    enable = true;
    platformTheme = lib.mkDefault "gnome";
    # platformTheme = "qt5ct";
    style = lib.mkDefault {
      package = pkgs.adwaita-qt6;
      name = "adwaita-dark";
      # package = pkgs.utterly-nord-plasma;
      # name = "Utterly Nord Plasma";
    };

  };
}
