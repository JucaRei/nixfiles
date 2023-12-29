{ pkgs, config, lib, inputs, hostname, username, ... }:
let
  nvidiaEnabled = (lib.elem "nvidia" config.services.xserver.videoDrivers);
in
{
  programs = {
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland.override {
        enableXWayland = true; # whether to enable XWayland
        legacyRenderer = if hostname == "nitro" then false else true; # false; # whether to use the legacy renderer (for old GPUs)
        withSystemd = if hostname == "nitro" then true else false; # whether to build with systemd support

        ### It seen's it been removed
        # Check if it has nvidia and nvidia Driver installed
        #enableNvidiaPatches =
        #  if nvidiaEnabled != true then
        #    false else true;
      };

      portalPackage = pkgs.xdg-desktop-portal-hyprland;

      # extraConfig =
      #   if nvidiaEnabled == true then
      #     (lib.mkBefore ''
      #       env = LIBVA_DRIVER_NAME,nvidia
      #       env = XDG_SESSION_TYPE,wayland
      #       env = GBM_BACKEND,nvidia-drm
      #       env = __GLX_VENDOR_LIBRARY_NAME,nvidia
      #       env = WLR_NO_HARDWARE_CURSORS,1
      #     '') else "";
    };
  };



  services = {
    xserver = {
      enable = true;
      displayManager = {
        sddm = {
          enable = true;
          wayland = {
            enable = true;
          };
        };
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
      LIBVA_DRIVER_NAME = if hostname != "air" || "zion" then lib.mkForce "nvidia" else lib.mkDefault "";
      NIXOS_OZONE_WL = "1";
      #GBM_BACKEND = "nvidia-drm";
      #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
      #WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      XDG_SESSION_TYPE = "wayland";
      # "enable-features" = "UseOzonePlatform,WaylandWindowDecorations";
      # ozone-platform-hint = "auto";
      # "ozone-platform" = "wayland";
    };
    systemPackages = with pkgs; [
      # gtk3
      # xdg-utils
      # libnotify
      # libevdev
      # # libsForQt5.libkscreen

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

    ] ++ (with pkgs.cinnamon; [
      # nemo-with-extensions
      # nemo-emblems
      # nemo-fileroller
      # folder-color-switcher
    ]) ++ (with pkgs.libsForQt5;[
      # dolphin
      # polkit-kde-agent
    ] ++ (with pkgs.lxqt; [
      # lxqt-policykit
    ]));
  };

  xdg = {
    portal = {
      enable = true;
      config = {
        common = {
          default = [
            "xdph"
            "gtk"
          ];
        };
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = [
            "gnome-keyring"
          ];
        };
      };
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
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
  services.gnome = {
    gnome-keyring.enable = true;
  };
}
