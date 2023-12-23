{ pkgs, config, lib, inputs, hostname, ... }:
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
      };

      ### It seen's it been removed
      # Check if it has nvidia and nvidia Driver installed
      # enableNvidiaPatches =
      #   if nvidiaEnabled != true then
      #     false else true;

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
  };

  environment = {
    sessionVariables = {
      # Hint electron apps to use wayland
      NIXOS_OZONE_WL = "1";
      LIBVA_DRIVER_NAME = if hostname != "air" || "zion" then lib.mkForce "nvidia" else lib.mkDefault "";
      XDG_SESSION_TYPE = "wayland";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
    };
    systemPackages = with pkgs; [
      gtk3
      libevdev

      ### Change to home-manager later
      mako # notification daemon
      kitty

      libsForQt5.polkit-kde-agent
      # ${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1
      # (toString [
      #   "swayidle" "-w"
      #   "timeout" 300 "'loginctl lock-session'"
      #   "timeout" 300 "'hyprctl dispatch dpms off'"
      #   "resume" "'hyprctl dispatch dpms on'"
      #   "before-sleep" "'loginctl lock-session'"
      #   "lock" "'waylock'"
      # ])

      waybar
      eww-wayland

      hyprpaper
      swww
      wofi
      hyprpicker
      wl-clip-persist
      # hyprsome

      pipewire
      wireplumber

      # qt5-wayland
      # qt6-wayland
      # qt5ct

    ];
  };

  xdg = {
    portal = {
      enable = true;
      config = {
        common = {
          default = [
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
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };

  systemd = {
    user.services.polkit-kde-authentication-agent-1 = {
      after = [ "graphical-session.target" ];
      description = "polkit-kde-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
