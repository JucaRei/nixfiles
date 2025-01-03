{ config, isInstall, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
in
{
  imports = [ ./greetd.nix ];
  environment = {
    # Enable HEIC image previews in Nautilus
    pathsToLink = [ "share/thumbnailers" ];
    homeBinInPath = true;
    sessionVariables = {
      # Make sure the cursor size is the same in all environments
      HYPRCURSOR_SIZE = 24;
      HYPRCURSOR_THEME = "catppuccin-mocha-blue-cursors";
      NIXOS_OZONE_WL = 1;
      QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
      DISPLAY = ":0";

      #WLR_RENDERER = "vulkan"; # Vulkan reduces power usage

      #WLR_DRM_NO_ATOMIC = 1;

      #__GL_GSYNC_ALLOWED = 0; # global vsync
      #__GL_SYNC_TO_VBLANK = 0;
      #__GL_VRR_ALLOWED = 0;
    };
    variables = mkIf (config.features.graphics.backend == "wayland" && config.features.graphics.gpu == "hybrid-nvidia") {
      # NVD_GPU = 1;
      NVD_GPU = "/dev/dri/renderD129";
    };
    systemPackages =
      with pkgs // pkgs.gnome;
      lib.optionals isInstall [
        hyprpicker
        # Enable HEIC image previews in Nautilus
        libheif
        libheif.out
        unstable.monitorets
        gnome-font-viewer
        nautilus # file manager
        zenity
        alacritty
        polkit_gnome
        wdisplays # display configuration
        wlr-randr
        unstable.catppuccin-cursors
      ];



    etc = {
      "backgrounds/Cat-1920px.png".source = ../../../../resources/dots/backgrounds/Cat-1920px.png;
      "backgrounds/Cat-2560px.png".source = ../../../../resources/dots/backgrounds/Cat-2560px.png;
      "backgrounds/Cat-3440px.png".source = ../../../../resources/dots/backgrounds/Cat-3440px.png;
      "backgrounds/Cat-3840px.png".source = ../../../../resources/dots/backgrounds/Cat-3840px.png;
      "backgrounds/Catppuccin-1920x1080.png".source = ../../../../resources/dots/backgrounds/Catppuccin-1920x1080.png;
      "backgrounds/Catppuccin-1920x1200.png".source = ../../../../resources/dots/backgrounds/Catppuccin-1920x1200.png;
      "backgrounds/Catppuccin-2560x1440.png".source = ../../../../resources/dots/backgrounds/Catppuccin-2560x1440.png;
      "backgrounds/Catppuccin-2560x1600.png".source = ../../../../resources/dots/backgrounds/Catppuccin-2560x1600.png;
      "backgrounds/Catppuccin-2560x2880.png".source = ../../../../resources/dots/backgrounds/Catppuccin-2560x2880.png;
      "backgrounds/Catppuccin-3440x1440.png".source = ../../../../resources/dots/backgrounds/Catppuccin-3440x1440.png;
      "backgrounds/Catppuccin-3840x2160.png".source = ../../../../resources/dots/backgrounds/Catppuccin-3840x2160.png;
      "backgrounds/Colorway-1920x1080.png".source = ../../../../resources/dots/backgrounds/Colorway-1920x1080.png;
      "backgrounds/Colorway-1920x1200.png".source = ../../../../resources/dots/backgrounds/Colorway-1920x1200.png;
      "backgrounds/Colorway-2560x1440.png".source = ../../../../resources/dots/backgrounds/Colorway-2560x1440.png;
      "backgrounds/Colorway-2560x1600.png".source = ../../../../resources/dots/backgrounds/Colorway-2560x1600.png;
      "backgrounds/Colorway-2560x2880.png".source = ../../../../resources/dots/backgrounds/Colorway-2560x2880.png;
      "backgrounds/Colorway-3440x1440.png".source = ../../../../resources/dots/backgrounds/Colorway-3440x1440.png;
      "backgrounds/Colorway-3840x2160.png".source = ../../../../resources/dots/backgrounds/Colorway-3840x2160.png;
    };
  };

  programs = {
    dconf.profiles.user.databases = [{
      settings = with lib.gvariant; {
        "org/gnome/desktop/interface" = {
          clock-format = "24h";
          color-scheme = "prefer-dark";
          cursor-size = mkInt32 24;
          cursor-theme = "catppuccin-mocha-blue-cursors";
          document-font-name = "Work Sans 11";
          font-name = "Work Sans 11";
          gtk-theme = "catppuccin-mocha-blue-standard";
          gtk-enable-primary-paste = true;
          icon-theme = "Papirus-Dark";
          monospace-font-name = "FiraCode Nerd Font Mono Medium 12";
          text-scaling-factor = mkDouble 1.0;
        };

        "org/gnome/desktop/sound" = {
          theme-name = "freedesktop";
        };

        "org/gtk/gtk4/Settings/FileChooser" = {
          clock-format = "24h";
        };

        "org/gtk/Settings/FileChooser" = {
          clock-format = "24h";
        };
      };
    }];
    file-roller = {
      enable = isInstall;
      package = pkgs.gnome.nautilus;
    };
    gnome-disks.enable = isInstall;
    hyprland = {
      enable = true;
      systemd.setPath.enable = true;
    };
    nautilus-open-any-terminal = {
      enable = true;
      terminal = "alacritty";
    };
    seahorse.enable = isInstall;
    udevil.enable = true;
  };
  security = {
    pam.services.hyprlock = { };
    polkit = {
      enable = true;
    };
  };

  services = {
    devmon.enable = true;
    gnome = {
      gnome-keyring.enable = isInstall;
      sushi.enable = isInstall;
    };
  };

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      configPackages = [ pkgs.hyprland ];
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        (xdg-desktop-portal-gtk.override {
          # Use the upstream default so this won't conflict with the xapp portal.
          buildPortalsInGnome = false;
        })
      ];
      config = {
        common = {
          default = [ "hyprland" "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      };
    };
  };
}
