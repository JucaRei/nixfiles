{ pkgs, lib, inputs, ... }:
{
  imports = [
    ../apps/terminal/tilix.nix
  ];

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
    dbus.packages = with pkgs; [
      budgie.budgie-control-center
    ];
    blueman.enable = true;
    gnome.gnome-keyring.enable = true;
    gnome.gnome-settings-daemon.enable = lib.mkDefault true;
    gnome.glib-networking.enable = lib.mkDefault true;
    geoclue2.enable = lib.mkDefault true; # for BCC's Privacy > Location Services panel.
    colord.enable = lib.mkDefault true; # for BCC's Color panel.
    gnome.at-spi2-core.enable = lib.mkDefault true; # for BCC's A11y panel.
    accounts-daemon.enable = lib.mkDefault true; # for BCC's Users panel.
    fprintd.enable = lib.mkDefault true; # for BCC's Users panel.
    # For BCC's Online Accounts panel.
    gnome.gnome-online-accounts.enable = lib.mkDefault true;
    gnome.gnome-online-miners.enable = true;

    # For BCC's Sharing panel.
    dleyna-renderer.enable = lib.mkDefault true;
    dleyna-server.enable = lib.mkDefault true;
    gnome.gnome-user-share.enable = lib.mkDefault true;
    gnome.rygel.enable = lib.mkDefault true;

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
            theme = lib.mkDefault { name = "Qogir"; package = pkgs.qogir-theme; };
            iconTheme = lib.mkDefault { name = "Qogir"; package = pkgs.qogir-icon-theme; };
            cursorTheme = lib.mkDefault { name = "Qogir"; package = pkgs.qogir-icon-theme; };
          };
        };
        autoLogin = {
          # enable = false;
          enable = true;
          #user = "${username}";
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
    extraPortals = with pkgs; [
      dg-desktop-portal-gtk # provides a XDG Portals implementation.
    ];
  };
}
