{ pkgs, config, lib, ... }@args:
let
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
in
{

  config = {
    home =
      let
        gio = pkgs.gnome.gvfs;
      in
      {
        packages = with pkgs; [
          ### Window
          wmname
          (nixgl sxhkd)
          (nixgl dunst)
          (nixgl rofi)
          (nixgl polybar)

          ### Theme
          lxappearance-gtk2

          ### File Manager
          gio # Virtual Filesystem support library
          cifs-utils # Tools for managing Linux CIFS client filesystems

          # Utils
          pamixer # Pulseaudio command line mixer
          imagemagick
          lm_sensors
        ];

        # sudo apt-get reinstall lxsession;sudo apt install --reinstall lightdm;sudo systemctl enable lightdm

        sessionVariables = {
          "_JAVA_AWT_WM_NONREPARENTING" = "1";
          GIO_EXTRA_MODULES = "${gio}/lib/gio/modules";
        };

        sessionPath = [ "$HOME/.local/bin" ];
      };

    dconf.settings = { };
    xsession = {
      enable = true;
      windowManager = {
        bspwm = {
          enable = true;
          package = nixgl pkgs.unstable.bspwm;
          # startupPrograms = [ ];
        };
      };
    };

    programs = {
      alacritty = {
        enable = true;
        package = nixgl pkgs.alacritty;
        settings = import ../../apps/terminal/alacritty.nix args;
      };
    };
  };
}
