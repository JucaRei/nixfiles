{ pkgs, lib, username, desktop, ... }:
let
  inherit (lib) mkIf mkOptionDefault mkDefault;
in
{
  # options = {
  #   programs.graphical.desktop.display-manager = {
  #     enable = lib.mkEnableOption "Enable the GTK greeter for LightDM";
  #   };
  # };

  config = {
    services.xserver = {
      displayManager = {
        # Disable autoSuspend; my Pantheon session kept auto-suspending
        # - https://discourse.nixos.org/t/why-is-my-new-nixos-install-suspending/19500
        gdm.autoSuspend = mkIf (desktop == "pantheon");
        lightdm = {
          enable = true;
          # greeter = {
          #   name = "gtk";
          #   package = pkgs.lightdm-gtk-greeter;
          #   enable = true;
          # };
          greeters = {
            #   tiny = {
            #     enable = true;
            #     label = {
            #       user = "${username}";
            #       pass = "Password";
            #       extraConfig = '''';
            #     };
            #   };
            pantheon = {
              enable = if desktop == "pantheon" then true else false;
            };
            gtk = let desk = (desktop == "mate" || desktop == "xfce4"); in {
              enable = if desk == true then true else false;
              cursorTheme.name = mkDefault "Yaru";
              cursorTheme.package = mkDefault pkgs.yaru-theme;
              cursorTheme.size = mkDefault 24;
              iconTheme.name = mkDefault "Yaru-magenta-dark";
              iconTheme.package = mkDefault pkgs.yaru-theme;
              theme.name = mkDefault "Yaru-magenta-dark";
              theme.package = mkDefault pkgs.yaru-theme;
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
              extraConfig = mkOptionDefault ''
                # background = Background file to use, either an image path or a color (e.g. #772953)
                font-name = Work Sans 12
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
                clock-format = %A, %B %d de %Y %H:%M:%S
              '';
              # clock-format = %a, %b %d  %H:%M
            };
          };
        };
      };
    };
    security.pam.services.lightdm.enableGnomeKeyring = mkIf (desktop == "mate" || desktop == "xfce4");
  };
}
