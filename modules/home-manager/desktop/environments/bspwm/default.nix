{ config, lib, pkgs, useNixGL ? false, osConfig ? null, ... }:
let
  inherit (lib) optionals;
  nixGL = import ../../../../../lib/nixGL.nix { inherit pkgs; };
  nixGLWrapper = if useNixGL then nixGL.wrapper else (x: x);

  isNixOS = osConfig != null;
in
{
  imports = [ ];
  xsession = {
    enable = true;
    windowManager = {
      bspwm = {
        enable = true;
        package = nixGLWrapper pkgs.bspwm;
        startupPrograms = [
          "sxhkd"
          "polybar"
        ];
      };
    };
  };

  home = {
    packages = with pkgs; [
      # Window Manager
      sxhkd

      # Misc
      gnome-keyring
      galculator

    ] ++ (optionals (!isNixOS) [
      glibcLocales

      ### Utils
      xorg.xinit
      xorg.libXcomposite
      xorg.libXinerama
      xorg.xprop
      xorg.libxcb
      xorg.xdpyinfo
      xorg.xkill
      xorg.xsetroot
      xorg.xwininfo
      xorg.xrandr
      xclip
      bc

      dialog # display dialog boxes from shell
      imagemagick # for display and convert
      at-spi2-atk

      # system
      xdg-utils
      xdg-user-dirs # create xdg user dirs
      xdg-desktop-portal-gtk
    ]);

    shellAliases = {
      is_picom_on = "pgrep -x 'picom' > /dev/null && echo 'on' || echo 'off'";
    };

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.local/share/applications"
    ];

    sessionVariables = {
      "_JAVA_AWT_WM_NONREPARENTING" = "1";
      # EDITOR = "micro";
      # TERMINAL = "alacritty";
      GLFW_IM_MODULE = "ibus";
      TERM = "xterm-256color";
      QT_STYLE_OVERRIDE = lib.mkDefault ""; # fix qt-override
      LOG_ICONS = "true"; # Enable icons in tooling since we have nerdfonts.
    };

  };

  services = {
    sxhkd = {
      enable = true;
    };
    # polybar = {
    #   enable = true;
    #   package = pkgs.polybar;
    #   config = {
    #     "bar/main" = {
    #       monitor = "DP-1";
    #       width = "100%";
    #       height = "24";
    #       font-0 = "monospace:size=10";
    #     };
    #   };
    # };
  };
}
