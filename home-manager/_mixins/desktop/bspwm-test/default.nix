{ pkgs, config, lib, ... }:
let
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
  _ = lib.getExe;
  windowMan = "${_ config.xsession.windowManager.bspwm.package}/bin/bspwm";
in
{
  config = {
    home = {
      packages = with pkgs; [
        wmname
        sxhkd
        xorg.xdpyinfo
        xorg.xkill
        xorg.xrandr
        xorg.xsetroot
        xorg.xwininfo
        xorg.xprop
        xorg.xrandr
        xfce.xfce4-terminal
      ];
      file = {
        ".xinitrc" = config.lib.file.mkOutOfStoreSymlink {
          executable = true;
          text = ''
            #!/bin/sh

            userresources=$HOME/.Xresources
            usermodmap=$HOME/.Xmodmap
            sysresources=/etc/X11/xinit/.Xresources
            sysmodmap=/etc/X11/xinit/.Xmodmap

            # merge in defaults and keymaps

            if [ -f $sysresources ]; then
                ${pkgs.xorg.xrdb}/bin/xrdb -merge $sysresources
            fi

            if [ -f $sysmodmap ]; then
                ${pkgs.xorg.xmodmap}/bin/xmodmap $sysmodmap
            fi

            if [ -f "$userresources" ]; then
                ${pkgs.xorg.xrdb}/bin/xrdb -merge "$userresources"
            fi

            if [ -f "$usermodmap" ]; then
                ${pkgs.xorg.xmodmap}/bin/xmodmap "$usermodmap"
            fi

            # start some nice programs

            if [ -d /etc/X11/xinit/xinitrc.d ] ; then
             for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
              [ -x "$f" ] && . "$f"
             done
             unset f
            fi

            exec ${windowMan}
          '';
        };
      };
    };
    xsession = {
      enable = true;
      windowManager = {
        bspwm = {
          enable = true;
          package = nixgl pkgs.bspwm;
        };
      };
    };
  };
}
