# { pkgs, username, lib, hostname, ... }: {
#   programs = lib.mkDefault {
#     hyprland = {
#       # Wayland compositor
#       enable = true;
#       # nvidiaPatches = lib.mkIf (hostname == "nitro");
#       xwayland = {
#         enable = true;
#       };
#     };
#     dconf = {
#       enable = true;
#     };
#   };

#   services = {
#     # xserver = {
#     #   displayManager = {
#     #     gdm = {
#     #       enable = true;
#     #       wayland = true;
#     #     };
#     #   };
#     # };

#     # dbus = {
#     #   enable = true;
#     #   # Make the gnome keyring work properly
#     #   packages = with pkgs; [
#     #     dconf
#     #     gnome3.gnome-keyring
#     #     gcr
#     #   ];
#     # };

#     # gnome = {
#     # gnome-keyring.enable = true;
#     # sushi.enable = true;
#     # };


#     # gvfs.enable = true;
#   };

#   environment = {
#     systemPackages = with pkgs; [
#       # wayland
#       # hyprland

#       ### Bars
#       # eww
#       # (waybar.overrideAttrs (oldAttrs: {
#       #   mesonFlags = oldAttrs.mesonFlags ++ [
#       #     "-Dexperimental=true"
#       #   ];
#       # }))

#       ### Notification daemon
#       # dunst
#       # libnotify

#       ### Wallpaper Daemon
#       swww
#       # hyprpaper
#       # swaybg
#       # wpaperd
#       # mpvpaer

#       ### Terminals
#       kitty
#       # alacritty
#       # wezterm
#       # st

#       ### App launcher
#       # rofi-wayland
#       # wofi # gtk rofi
#       # bemenu
#       # fuzzel
#       # toffi

#       # polkit_gnome
#       # gnome.zenity
#       # ranger
#       # ueberzug
#       # picom
#       # rofi
#       # dolphin
#       # qutebrowser
#       # light
#       # shotman
#     ];

#     sessionVariables = {

#       #WLR_NO_HARDWARE_CURSORS = "1"; # If your cursor becomes invisible
#       NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
#     };
#   };

#   security = {
#     pam.services = {
#       swaylock = { };
#       # gtklock = { };
#       login.enableGnomeKeyring = true;
#     };
#   };

#   # hardware = lib.mkForce {
#   #   opengl.enable = true; #Opengl
#   #   # nvidia.modesetting.enable = true; # Most wayland compositors need this
#   # };

#   xdg.portal = {
#     enable = true;
#     #extraPortals = with pkgs; [
#     # xdg-desktop-portal-hyprland # provides a XDG Portals implementation.
#     # ];
#   };
# }

{ inputs, pkgs, ... }:
{
  services = {
    xserver = {
      displayManager = {
        sddm = {
          enable = true;
          wayland = true;
        };
      };
    };
    dbus.enable = true;
    tumbler.enable = true;
  };

  programs.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    # package = (inputs.hyprland.packages.${pkgs.system}.hyprland.override { legacyRenderer = true; });
    # package = pkgs.unstable.hyprland.overrideAttrs (_: {
    #   mesonFlags = [ "-DLEGACY_RENDERER:STRING=true" ];
    # });
    package = pkgs.unstable.hyprland.overrideAttrs (oldAttrs: {
      # mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" "-DLEGACY_RENDERER:STRING=true"  ];
      mesonFlags = oldAttrs.mesonFlags ++ [ "-DLEGACY_RENDERER:STRING=true" ];
    });
    xwayland.enable = true;
  };

  xdg.portal = {
    # enable = true;
    # extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    wlr = {
      enable = true;
    };
  };

  security = {
    polkit.enable = true;
  };

  environment = {
    systemPackages = with pkgs.gnome; [
      adwaita-icon-theme
      nautilus
      gnome-calendar
      gnome-boxes
      gnome-system-monitor
      gnome-control-center
      gnome-weather
      gnome-calculator
      gnome-software # for flatpak
    ];
    sessionVariables = {
      POLKIT_AUTH_AGENT = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
      # LIBVA_DRIVER_NAME = "nvidia";
      XDG_SESSION_TYPE = "wayland";
      # GBM_BACKEND = "nvidia-drm";
      # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      SDL_VIDEODRIVER = "wayland";
      # _JAVA_AWT_WM_NONREPARENTING = "1";
      CLUTTER_BACKEND = "wayland";
      # WLR_RENDERER = "vulkan";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      GTK_USE_PORTAL = "1";
      NIXOS_XDG_OPEN_USE_PORTAL = "1";
    };
  };

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  services = {
    gvfs.enable = true;
    devmon.enable = true;
    udisks2.enable = true;
    upower.enable = true;
    accounts-daemon.enable = true;
    gnome = {
      evolution-data-server.enable = true;
      glib-networking.enable = true;
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
    };
  };
}
