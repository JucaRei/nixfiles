# { inputs, pkgs, ... }:
# {
#   services = {
#     xserver = {
#       displayManager = {
#         sddm = {
#           enable = true;
#           wayland = true;
#         };
#       };
#     };
#     dbus.enable = true;
#     tumbler.enable = true;
#   };
#   programs.hyprland = {
#     enable = true;
#     # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
#     # package = (inputs.hyprland.packages.${pkgs.system}.hyprland.override { legacyRenderer = true; });
#     # package = pkgs.unstable.hyprland.overrideAttrs (_: {
#     #   mesonFlags = [ "-DLEGACY_RENDERER:STRING=true" ];
#     # });
#     package = pkgs.unstable.hyprland.overrideAttrs (oldAttrs: {
#       # mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" "-DLEGACY_RENDERER:STRING=true"  ];
#       mesonFlags = oldAttrs.mesonFlags ++ [ "-DLEGACY_RENDERER:STRING=true" ];
#     });
#     xwayland.enable = true;
#   };
#   xdg.portal = {
#     # enable = true;
#     # extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
#     wlr = {
#       enable = true;
#     };
#   };
#   security = {
#     polkit.enable = true;
#   };
#   environment = {
#     systemPackages = with pkgs.gnome; [
#       adwaita-icon-theme
#       nautilus
#       gnome-calendar
#       gnome-boxes
#       gnome-system-monitor
#       gnome-control-center
#       gnome-weather
#       gnome-calculator
#       gnome-software # for flatpak
#     ];
#     sessionVariables = {
#       POLKIT_AUTH_AGENT = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
#       GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
#       # LIBVA_DRIVER_NAME = "nvidia";
#       XDG_SESSION_TYPE = "wayland";
#       # GBM_BACKEND = "nvidia-drm";
#       # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
#       WLR_NO_HARDWARE_CURSORS = "1";
#       NIXOS_OZONE_WL = "1";
#       MOZ_ENABLE_WAYLAND = "1";
#       SDL_VIDEODRIVER = "wayland";
#       # _JAVA_AWT_WM_NONREPARENTING = "1";
#       CLUTTER_BACKEND = "wayland";
#       # WLR_RENDERER = "vulkan";
#       XDG_CURRENT_DESKTOP = "Hyprland";
#       XDG_SESSION_DESKTOP = "Hyprland";
#       GTK_USE_PORTAL = "1";
#       NIXOS_XDG_OPEN_USE_PORTAL = "1";
#     };
#   };
#   systemd = {
#     user.services.polkit-gnome-authentication-agent-1 = {
#       description = "polkit-gnome-authentication-agent-1";
#       wantedBy = [ "graphical-session.target" ];
#       wants = [ "graphical-session.target" ];
#       after = [ "graphical-session.target" ];
#       serviceConfig = {
#         Type = "simple";
#         ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
#         Restart = "on-failure";
#         RestartSec = 1;
#         TimeoutStopSec = 10;
#       };
#     };
#   };
#   services = {
#     gvfs.enable = true;
#     devmon.enable = true;
#     udisks2.enable = true;
#     upower.enable = true;
#     accounts-daemon.enable = true;
#     gnome = {
#       evolution-data-server.enable = true;
#       glib-networking.enable = true;
#       gnome-keyring.enable = true;
#       gnome-online-accounts.enable = true;
#     };
#   };
# }
{ pkgs, config, lib, inputs, hostname, username, ... }:
let
  nvidiaEnabled = lib.elem "nvidia" config.services.xserver.videoDrivers;
in
{
  programs = {
    hyprland = {
      enable = true;
      # package = inputs.hyprland.packages.${pkgs.system}.hyprland.override {
      #   enableXWayland = true; # whether to enable XWayland
      #   legacyRenderer = if (hostname == "nitro") then false else true; # false; # whether to use the legacy renderer (for old GPUs)
      #   withSystemd = if (hostname == "nitro") then true else false; # whether to build with systemd support
      # };

      package = inputs.hyprland.packages.${pkgs.system}.hyprland.override {
        legacyRenderer = true;
        mesa = pkgs.mesa;
      };
      xwayland.enable = true;

      # package = pkgs.unstable.hyprland.override {
      #   enableXWayland = true; # whether to enable XWayland
      #   legacyRenderer = if (hostname == "nitro") then false else true; # false; # whether to use the legacy renderer (for old GPUs)
      #   withSystemd = if (hostname == "nitro") then true else false; # whether to build with systemd support
      # };
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
  };

  services = {
    xserver = {
      enable = true;
      displayManager = {
        sddm = {
          enable = true;
          wayland = { enable = true; };
          theme = "astronaut";
          autoNumlock = true;
        };
        defaultSession = "hyprland";
      };
    };
    dbus.enable = true;

    # greetd display manager
    #   greetd =
    #     let
    #       session = {
    #         command = "${lib.getExe config.programs.hyprland.package}";
    #         user = "${username}";
    #       };
    #     in
    #     {
    #       enable = true;
    #       settings = {
    #         terminal.vt = 1;
    #         default_session = session;
    #         initial_session = session;
    #       };
    #     };
  };

  environment = {
    sessionVariables = {
      # Hint electron apps to use wayland
      # LIBVA_DRIVER_NAME =
      #   if hostname != "air" || "zion"
      #   then lib.mkForce "nvidia"
      #   else lib.mkDefault "";


      # override the setting in hyprland module
      # priority of mkDefault is 1000
      # default priority is 100
      NIXOS_OZONE_WL = lib.mkOverride 990 "";
      # NIXOS_OZONE_WL = "1";
      #GBM_BACKEND = "nvidia-drm";
      #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
      #WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
      SDL_VIDEODRIVER = "wayland";
      QT_QPA_PLATFORM = "wayland-egl";
      WLR_NO_HARDWARE_CURSORS = "1";
      XDG_SESSION_TYPE = "wayland";
      # DCONF_PROFILE = "sway";
      # "enable-features" = "UseOzonePlatform,WaylandWindowDecorations";
      # ozone-platform-hint = "auto";
      # "ozone-platform" = "wayland";

      XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";
    };
    #loginShellInit = ''
    #  dbus-update-activation-environment --systemd DISPLAY
    #'';
    # eval $(gnome-keyring-daemon --start --components=ssh,secrets)
    # eval $(ssh-agent)
    systemPackages = with pkgs;
      [
        # gtk3
        # xdg-utils
        # libnotify
        # libevdev
        # # libsForQt5.libkscreen
        pkgs.astronaut-sddm

        ### Change to home-manager later
        # mako # notification daemon
        # alacritty

        # ${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1
        # (toString [
        #   "swayidle" "-w"
        #   "timeout" 300 "'loginctl lock-session'"
        #   "timeout" 300 "'hyprctl dispatch dpms off'"
        #   "resume" "'hyprctl dispatch dpms on'"
        #   "before-sleep" "'loginctl lock-session'"
        #   "lock" "'waylock'"
        # ])

        # waybar
        # eww-wayland

        # hyprpaper
        # swww
        # wofi
        # hyprpicker
        # wl-clip-persist
        # hyprsome

        # pipewire
        # wireplumber

        # qt5-wayland
        # qt6-wayland
        # qt5ct
      ]
      ++ (with pkgs.cinnamon; [
        # nemo-with-extensions
        # nemo-emblems
        # nemo-fileroller
        # folder-color-switcher
      ])
      ++ (with pkgs.libsForQt5;
      [
        # dolphin
        # polkit-kde-agent
      ]
      ++ (with pkgs.lxqt; [
        # lxqt-policykit
      ]));

    # Move ~/.Xauthority out of $HOME (setting XAUTHORITY early isn't enough)
    # extraInit = ''
    #   xhost +SI:localuser:root;

    #   export XAUTHORITY=/tmp/Xauthority
    #   [ -e ~/.Xauthority ] && mv -f ~/.Xauthority "$XAUTHORITY"

    # '';

    # fix root on wayland
    # extraInit = ''
    # xhost +SI:localuser:root
    # '';
  };

  xdg = {
    portal = {
      enable = true;
      wlr.enable = true;
      config = {
        common = { default = [ "xdph" "gtk" ]; };
        hyprland = {
          default = [ "hyprland" "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      };
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };

  # unlock GPG keyring on login
  security = {
    pam.services = {
      swaylock = {
        text = ''
          auth include login
        '';
      };
      # greetd.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
    };
  };
  services.gnome = { gnome-keyring.enable = true; };
}
