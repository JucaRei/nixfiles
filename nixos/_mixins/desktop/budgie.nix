{ pkgs, lib, inputs, username, ... }: {

  environment = {
    budgie.excludePackages = with pkgs; [
      mate.mate-terminal
      mate.eom
      mate.pluma
      mate.atril
      mate.engrampa
      mate.mate-calc
      mate.mate-terminal
      mate.mate-system-monitor
      vlc
    ];
    systemPackages = with pkgs; [
      # inputs.nix-software-center.packages.${system}.nix-software-center
      budgie.budgie-backgrounds
      budgie.budgie-control-center
      budgie.budgie-desktop-view
      budgie.budgie-screensaver
      qogir-theme
      tilix

      # Required by the Budgie Desktop session.
      (gnome.gnome-session.override { gnomeShellSupport = false; })

      # Required by Budgie Menu.
      gnome-menus

      # Required by Budgie Control Center.
      gnome.zenity

      # Update user directories.
      xdg-user-dirs
    ];
  };

  # Qt application style.
  qt = lib.mkForce {
    enable = true;
    style = "gtk2";
    platformTheme = "gtk2";
  };

  environment.pathsToLink = [
    "/share" # TODO: https://github.com/NixOS/nixpkgs/issues/47173
  ];

  # Required by Budgie Desktop.
  programs.dconf.enable = true;

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
    blueman.enable = true;

    colord.enable = lib.mkDefault true; # for BCC's Color panel.
    accounts-daemon.enable = lib.mkDefault true; # for BCC's Users panel.
    fprintd.enable = lib.mkDefault true; # for BCC's Users panel.
    gnome = {
      at-spi2-core.enable = lib.mkDefault true; # for BCC's A11y panel.
      gnome-keyring.enable = true;
      gnome-settings-daemon.enable = lib.mkDefault true;
      glib-networking.enable = lib.mkDefault true;
      # For BCC's Online Accounts panel.
      gnome-online-accounts.enable = lib.mkDefault true;
      gnome-online-miners.enable = true;
      rygel.enable = lib.mkDefault true;
      gnome-user-share.enable = lib.mkDefault true;
    };
    # For BCC's Sharing panel.
    dleyna-renderer.enable = lib.mkDefault true;
    dleyna-server.enable = lib.mkDefault true;

    xserver = {
      enable = true;
      displayManager = {
        # gdm = {
        #   enable = true;
        #   wayland = true;
        # };
        lightdm = {
          enable = true;
          greeters.slick = {
            enable = true;
            theme = lib.mkDefault { name = "Qogir"; };
            iconTheme = lib.mkDefault { name = "Qogir"; };
            cursorTheme = lib.mkDefault { name = "Qogir"; };
          };
        };
        autoLogin = {
          # enable = false;
          enable = true;
          user = "${username}";
          # };
        };
      };

      desktopManager = {
        budgie = {
          enable = lib.mkDefault true;
          sessionPath = [ pkgs.budgie.budgie-desktop-view ];
          extraGSettingsOverrides = ''
            [com.solus-project.icon-tasklist:Budgie]
            pinned-launchers=["firefox.desktop", "nixos-manual.desktop", "mate-terminal.desktop", "nemo.desktop", "gparted.desktop", "io.calamares.calamares.desktop"] '';
          extraGSettingsOverridePackages = [ ];
          extraPlugins = with pkgs; [ budgiePlugins.budgie-analogue-clock-applet ];
        };
      };
    };
  };
  security = {
    # xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gnome ];
    pam.services = { budgie-screensaver.allowNullPassword = true; };
    # Required by Budgie's Polkit Dialog.
    polkit.enable = lib.mkDefault true;
  };
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    ### Until 23.05
    # extraPortals = with pkgs; [
    #   xdg-desktop-portal-gtk # provides a XDG Portals implementation.
    # ];

    ## 23.11
    config = {
      common = { default = [ "gtk" ]; };
      budgie = {
        default = [ "gnome" "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };
  };
}
