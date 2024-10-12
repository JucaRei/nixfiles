{ pkgs, lib, inputs, username, ... }:
let
  inherit (lib) mkIf mkDefault mkForce;
in
{

  environment = {
    budgie.excludePackages = with pkgs // pkgs.mate; [
      mate-terminal
      eom
      pluma
      atril
      engrampa
      mate-calc
      mate-terminal
      mate-system-monitor
      vlc
    ];
    systemPackages = with pkgs // pkgs.budgie // pkgs.gnome; [
      # inputs.nix-software-center.packages.${system}.nix-software-center
      budgie-backgrounds
      budgie-control-center
      budgie-desktop-view
      budgie-screensaver
      qogir-theme
      tilix

      # Required by the Budgie Desktop session.
      # (gnome.gnome-session.override { gnomeShellSupport = false; })

      # Required by Budgie Menu.
      gnome-menus

      # Required by Budgie Control Center.
      zenity

      # Update user directories.
      xdg-user-dirs
    ];
  };

  # Qt application style.
  # qt = lib.mkForce {
  #   enable = true;
  #   style = "gtk2";
  #   platformTheme = "gtk2";
  # };

  environment.pathsToLink = [
    "/share" # TODO: https://github.com/NixOS/nixpkgs/issues/47173
  ];

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
        lightdm = {
          enable = true;
          greeters.slick = {
            enable = true;
            theme = mkDefault { name = "Qogir"; };
            iconTheme = mkDefault { name = "Qogir"; };
            cursorTheme = mkDefault { name = "Qogir"; };
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
          sessionPath = [ pkgs.budgie.budgie-desktop-view ];
          extraGSettingsOverrides = ''
            [com.solus-project.icon-tasklist:Budgie]
            pinned-launchers=["floorp.desktop", "nixos-manual.desktop", "mate-terminal.desktop", "nemo.desktop", "gparted.desktop", "io.calamares.calamares.desktop"] '';
          extraGSettingsOverridePackages = [ ];
          extraPlugins = with pkgs; [ budgiePlugins.budgie-analogue-clock-applet ];
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
