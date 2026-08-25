{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;

  cfg = config.desktop.display-managers.lightdm;
in
{
  options = {
    desktop.display-managers.lightdm = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable LightDM as the display manager.";
      };
    };
  };

  config = mkIf (cfg.enable) {
    services = {
      xserver = {
        enable = true;
        displayManager = {
          lightdm = {
            enable = true;
            background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
            greeters = {
              # mini = {
              #   enable = true;
              #   user = "${username}";
              #   extraConfig = ''
              #     font-size = 1.0em
              #     font = "Iosevka"

              #     [greeter]
              #     show-password-label = false
              #     password-label-text = ""
              #     password-input-width = 30
              #     password-alignment = left
              #   '';
              # };
              gtk = {
                theme = {
                  name = "Dracula";
                  package = pkgs.dracula-theme;
                  # package = pkgs.tokyo-night-gtk;
                };
                cursorTheme = {
                  name = "Dracula-cursors";
                  package = pkgs.dracula-theme;
                  size = 16;
                };
                iconTheme.name = lib.mkDefault "Yaru-magenta-dark";
                iconTheme.package = pkgs.yaru-theme;
                indicators = [
                  "~session"
                  "~host"
                  "~spacer"
                  "~clock"
                  "~spacer"
                  "~a11y"
                  "~power"
                ];
                # https://github.com/Xubuntu/lightdm-gtk-greeter/blob/master/data/lightdm-gtk-greeter.conf
                extraConfig = ''
                  # background = Background file to use, either an image path or a color (e.g. #772953)
                  # font-name = Work Sans 12
                  xft-antialias = true
                  xft-dpi = 96
                  xft-hintstyle = slight
                  xft-rgba = rgb

                  active-monitor = #cursor
                  # position = x y ("50% 50%" by default)  Login window position
                  # default-user-image = Image used as default user icon, path or #icon-name
                  hide-user-image = false
                  round-user-image = false
                  highlight-logged-user = true
                  panel-position = top
                  clock-format = %a, %b %d  %H:%M
                '';
              };
            };
            extraSeatDefaults = ''
              greeter-hide-users=false
              #greeter-show-manual-login=true
            '';
          };
        };
      };
    };

    # environment = {
    #   etc = {
    #     "X11/xinit/xinitrc".source = pkgs.writeShellScript "xinitrc" ''
    #       if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
    #         eval $(dbus-launch --exit-with-session --sh-syntax)
    #       fi
    #       systemctl --user import-environment DISPLAY XAUTHORITY

    #       if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    #         dbus-update-activation-environment DISPLAY XAUTHORITY
    #       fi
    #       systemctl --user start nixos-fake-graphical-session.target

    #       ${pkgs.runtimeShell} ${pkgs.xfce.xfce4-session.xinitrc} &
    #       waitPID=$!
    #       wait $waitPID

    #       # stop services and all subprocesses
    #       systemctl --user stop nixos-fake-graphical-session.target
    #       kill 0
    #     '';
    #   };
    # };

    # systemd.user.targets.nixos-fake-graphical-session = {
    #   description = "Fake Graphical Session Target";
    #   wants = [ "graphical-session.target" ]; # Or your custom services
    #   wantedBy = [ "multi-user.target" ]; # Adjust as needed
    # };
  };
}
