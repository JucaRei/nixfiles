{ pkgs, lib, ... }:
let
  inherit (lib) mkDefault mkForce;
in
{
  programs.graphical.desktop.backend = "x11";

  environment = {
    budgie.excludePackages = with pkgs // pkgs.mate // pkgs.gnome; [
      mate-terminal
      eom
      pluma
      atril
      engrampa
      mate-calc
      mate-terminal
      gnome-terminal
      mate-system-monitor
      vlc
      geary
    ];
    systemPackages = with pkgs // pkgs.budgie // pkgs.gnome // pkgs.gnomeExtensions; [
      # inputs.nix-software-center.packages.${system}.nix-software-center
      budgie-backgrounds
      budgie-control-center
      budgie-desktop-view
      budgie-screensaver
      magpie
      qogir-theme
      brightness-panel-menu-indicator
      tilix

      # Required by the Budgie Desktop session.
      # (gnome-session.override { gnomeShellSupport = false; })

      # Required by Budgie Menu.
      gnome-menus

      # Required by Budgie Control Center.
      zenity

      # Update user directories.
      xdg-user-dirs
    ];

    # Qt application style.
    # qt = mkForce {
    #   enable = true;
    #   style = "gtk2";
    #   platformTheme = "gtk2";
    # };

    sessionVariables."G_SLICE" = "always-malloc";

    pathsToLink = [
      "/share" # TODO: https://github.com/NixOS/nixpkgs/issues/47173
    ];
  };
  # Enable some programs to provide a complete desktop
  programs = {
    light.enable = true;
    gnome-disks.enable = true;
    nm-applet.enable = true;
    seahorse.enable = true;
    #system-config-printer.enable = true;
  };

  # Enable services to round out the desktop
  services = {
    dbus.packages = with pkgs; [ budgie.budgie-control-center ];
    # blueman.enable = true;

    colord.enable = mkDefault true; # for BCC's Color panel.
    accounts-daemon.enable = mkDefault true; # for BCC's Users panel.
    fprintd.enable = mkDefault true; # for BCC's Users panel.
    gnome = {
      at-spi2-core.enable = mkDefault true; # for BCC's A11y panel.
      gnome-keyring.enable = true;
      gnome-settings-daemon.enable = mkDefault true;
      glib-networking.enable = mkDefault true;
      # For BCC's Online Accounts panel.
      gnome-online-accounts.enable = mkDefault true;
      gnome-online-miners.enable = true;
      rygel.enable = mkForce false;
      gnome-user-share.enable = mkDefault true;
    };
    # For BCC's Sharing panel.
    dleyna-renderer.enable = mkDefault true;
    dleyna-server.enable = mkDefault true;

    xserver = {
      enable = true;
      displayManager = {
        lightdm = {
          enable = true;
          greeters.slick = {
            enable = true;
            theme = mkForce {
              name = "Qogir-Dark";
            };
            iconTheme = mkForce {
              name = "Qogir-Dark";
            };
            cursorTheme = mkForce {
              name = "Qogir-Dark";
            };
            draw-user-backgrounds = false;
          };
        };
        # autoLogin = {
        #   enable = false;
        #   user = "${username}";
        #   # };
        # };
      };

      desktopManager = {
        budgie = {
          enable = mkDefault true;
          sessionPath = with pkgs.budgie // pkgs.gnome; [ budgie-desktop-view gpaste ];
          extraGSettingsOverrides = ''
            [com.solus-project.icon-tasklist:Budgie]
              pinned-launchers=["firefox.desktop", "com.gexperts.Tilix.desktop", "nemo.desktop", "code.desktop", "io.calamares.calamares.desktop"]

            [org.gnome.desktop.interface:Budgie]
              gtk-theme="Qogir-Dark"
          '';
          extraGSettingsOverridePackages = [ ];
          extraPlugins = with pkgs // pkgs.budgiePlugins; [
            budgie-media-player-applet
            budgie-analogue-clock-applet
            budgie-user-indicator-redux
          ];
        };
      };
    };
  };
  security = {
    pam.services = { budgie-screensaver.allowNullPassword = true; };
  };

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      configPackages = [ pkgs.budgie.budgie-session ];
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = [ "gnome" "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          "org.freedesktop.portal.FileChooser" = [ "xdg-desktop-portal-gtk" ];
        };
      };
    };
    terminal-exec = {
      enable = true;
      settings = {
        default = [ "com.gexperts.Tilix.desktop" ];
      };
    };
  };
}
