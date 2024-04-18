{ pkgs, config, ... }:
let
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
in
{
  home.file.xinit = {
    target = ".xinitrc";
    text = ''
        [ -f ~/.xprofile ] && . ~/.xprofile
        [ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

        if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
            eval $(dbus-launch --exit-with-session --sh-syntax)
        fi

        ${pkgs.systemd}/bin/systemctl --user import-environment DISPLAY XAUTHORITY

        if command -v dbus-update-activation-environment >/dev/null 2>&1; then
      	  dbus-update-activation-environment DISPLAY XAUTHORITY
        fi

        ${pkgs.systemd}/bin/systemctl --user start graphical-session.target

        ${pkgs.autorandr}/bin/autorandr --change

        ${pkgs.sxhkd}/bin/sxhkd &

        exec ${(nixgl pkgs.bspwm)}/bin/bspwm
    '';
    # text = ''
    #   userresources=$HOME/.Xresources
    #   usermodmap=$HOME/.Xmodmap
    #   sysresources=/etc/X11/xinit/.Xresources
    #   sysmodmap=/etc/X11/xinit/.Xmodmap

    #   # merge in defaults and keymaps

    #   if [ -f $sysresources ]; then

    #       xrdb -merge $sysresources

    #   fi

    #   if [ -f $sysmodmap ]; then
    #       xmodmap $sysmodmap
    #   fi

    #   if [ -f "$userresources" ]; then
    #       xrdb -merge "$userresources"
    #   fi

    #   if [ -f "$usermodmap" ]; then
    #       xmodmap "$usermodmap"
    #   fi

    #   # start some nice programs

    #   if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    #    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
    #     [ -x "$f" ] && . "$f"
    #    done
    #    unset f
    #   fi
    # '';
    executable = true;
  };
}
