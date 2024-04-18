{ pkgs, config, ... }:
let
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
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
    file = {
      ".xinitrc" = {
        executable = true;
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
      };
    };
  };
}
