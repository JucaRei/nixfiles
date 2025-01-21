{ lib, pkgs, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkDefault;
in
lib.mkIf isLinux {
  # https://discourse.nixos.org/t/struggling-to-configure-gtk-qt-theme-on-laptop/42268/
  home = {
    packages = with pkgs; [
      (catppuccin-kvantum.override mkDefault {
        accent = mkDefault "blue";
        variant = mkDefault "mocha";
      })
      libsForQt5.qtstyleplugin-kvantum
      libsForQt5.qt5ct
    ];
  };

  qt = {
    enable = mkDefault true;
    platformTheme = {
      # name = mkDefault "gtk";
      name = mkDefault "kvantum";
    };
    style = {
      name = mkDefault "kvantum";
    };
  };

  systemd.user.sessionVariables = {
    QT_STYLE_OVERRIDE = mkDefault "kvantum";
  };

  xdg.configFile = mkDefault {
    kvantum = {
      target = "Kvantum/kvantum.kvconfig";
      text = lib.generators.toINI { } { General.theme = "Catppuccin-Mocha-Blue"; };
    };
    qt5ct = {
      target = "qt5ct/qt5ct.conf";
      text = lib.generators.toINI { } {
        Appearance = {
          icon_theme = mkDefault "Papirus-Dark";
        };
      };
    };
    qt6ct = {
      target = "qt6ct/qt6ct.conf";
      text = lib.generators.toINI { } {
        Appearance = {
          icon_theme = mkDefault "Papirus-Dark";
        };
      };
    };
  };
}
