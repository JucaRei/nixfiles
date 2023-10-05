{ pkgs
, lib
, inputs
, ...
}:
let
  system = "x86_64-linux";
in
{
  imports = [
    #inputs.budgie.nixosModules.default
  ];

  environment.budgie.excludePackages = with pkgs; [ mate.mate-terminal ];

  # environment.systemPackages = [
  #   inputs.nix-software-center.packages.${system}.nix-software-center
  # ];

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
    blueman.enable = true;
    gnome.gnome-keyring.enable = true;
    xserver = {
      enable = true;
      displayManager = {
        #gdm = {
        #  enable = true;
        #  wayland = true;
        #};
        lightdm = {
          enable = true;
          greeters.slick.enable = true;
        };
        autoLogin = {
          enable = false;
          #enable = true;
          #user = "${username}";
        };
      };

      desktopManager = {
        budgie = {
          enable = lib.mkForce true;
          sessionPath = [ ];
          extraGSettingsOverrides = ''          
            [com.solus-project.icon-tasklist:Budgie]
            pinned-launchers=["firefox.desktop", "nixos-manual.desktop", "mate-terminal.desktop", "nemo.desktop", "gparted.desktop", "io.calamares.calamares.desktop"] '';
          extraGSettingsOverridePackages = [ ];
          extraPlugins = with pkgs; [ budgiePlugins.budgie-analogue-clock-applet ];
        };
      };
    };
  };
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gnome ];
  security.pam.services = { budgie-screensaver.allowNullPassword = true; };
}
