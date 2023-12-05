{ inputs, lib, pkgs, ... }: {
  imports = [
    ../config/qt/qt-style.nix
    ../apps/terminal/tilix.nix
  ];

  # Exclude the elementary apps I don't use
  environment = {
    pantheon.excludePackages = with pkgs.pantheon; [
      elementary-camera
      elementary-music
      elementary-photos
      elementary-videos
      epiphany
    ];

    # App indicator
    # - https://discourse.nixos.org/t/anyone-with-pantheon-de/28422
    # - https://github.com/NixOS/nixpkgs/issues/144045#issuecomment-992487775
    pathsToLink = [ "/libexec" ];

    # Add additional apps and include Yaru for syntax highlighting
    systemPackages = with pkgs; [
      snapshot # camera
      appeditor # elementary OS menu editor
      # celluloid # Video Player
      formatter # elementary OS filesystem formatter
      # gthumb # Image Viewer
      loupe # Image viewer
      gnome.simple-scan # Scanning
      indicator-application-gtk3 # App Indicator
      pantheon.sideload # elementary OS Flatpak installer
      torrential # elementary OS torrent client
      yaru-theme
      usbimager
      # inputs.nix-software-center.packages.${system}.nix-software-center
      # hacked-cursor
    ];
  };

  # Add GNOME Disks, Pantheon Tweaks and Seahorse
  programs = {
    gnome-disks.enable = true;
    pantheon-tweaks.enable = true;
    seahorse.enable = true;
  };

  services = {
    pantheon.apps.enable = true;

    xserver = {
      enable = true;
      displayManager = {
        lightdm.enable = true;
        lightdm.greeters.pantheon.enable = true;
      };

      desktopManager = {
        pantheon = {
          enable = true;
          extraWingpanelIndicators = with pkgs; [
            monitor
            wingpanel-indicator-ayatana
          ];
        };
      };
    };
  };

  # App indicator
  # - https://github.com/NixOS/nixpkgs/issues/144045#issuecomment-992487775
  systemd.user.services.indicatorapp = {
    description = "indicator-application-gtk3";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.indicator-application-gtk3}/libexec/indicator-application/indicator-application-service";
    };
  };
}
