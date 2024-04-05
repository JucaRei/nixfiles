{ pkgs, config, lib, ... }:
let
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
  alacrity = ../../apps/terminal/alacritty.nix { inherit config; };


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
          bpswm
          wmname
          sxhkd
          dunst
          rofi
          polybar

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

        sessionVariables = {
          "_JAVA_AWT_WM_NONREPARENTING" = "1";
          GIO_EXTRA_MODULES = "${gio}/lib/gio/modules";
        };

        sessionPath = [ "$HOME/.local/bin" ];
      };

    dconf.settings = { };

    programs = {
      alacritty = {
        enable = true;
        package = nixgl pkgs.alacritty;
        settings = "${alacrity}";
      };
    };
  };
}
