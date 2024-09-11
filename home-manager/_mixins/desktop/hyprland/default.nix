{ pkgs, lib, config, inputs, hostname, ... }:
let
  nvidiaEnabled = lib.elem "nvidia" config.services.xserver.videoDrivers;
  isSystemd = if ("${pkgs.toybox}/bin/ps -p 1 -o comm=" == "systemd") then true else false;
in
{
  imports = [ ./themes/my-theme ];
  config = {
    custom.features.isWayland = true;
    home = {
      packages = with pkgs; [
        # kitty # terminal
        # mako # notification daemon
        # libsForQt5.polkit-kde-agent # polkit agent
        libcamera
        dmenu
        bibata-cursors
        pavucontrol
        # nwg-look
        qt6Packages.qtstyleplugin-kvantum
        libsForQt5.qtstyleplugin-kvantum
        libsForQt5.qt5ct
        qt6.qtwayland
        libsForQt5.qt5.qtwayland
        xdg-desktop-portal-hyprland
        xdg-utils
        libnotify
        libevdev
        gtk3
        xdg-utils
        xfce.tumbler
        xfce.xfce4-power-manager
      ];
    };
    wayland = {
      windowManager = {
        hyprland = {
          # enable = if hostname != "zion" then true else false;
          enable = isSystemd;
          # Check if it has nvidia and nvidia Driver installed
          # enableNvidiaPatches = if nvidiaEnabled != true then false else true;
          # enableNvidiaPatches = true;
          package = inputs.hyprland.packages.${pkgs.system}.hyprland.override {
            enableXWayland = true; # whether to enable XWayland
            legacyRenderer =
              if hostname == "nitro"
              then false
              else true; # false; # whether to use the legacy renderer (for old GPUs)
            withSystemd =
              if hostname == "nitro"
              then true
              else false; # whether to build with systemd support
          };
          # extraConfig = '''';
          # finalPackage = '''';
          # plugins = [];
          # settings = {};
          systemd = {
            enable =
              if hostname != "zion"
              then true
              else false;
            # enable = false;
            # extraCommands = "";
            # variable = [];

            # Same as default, but stop graphical-session too
            extraCommands = lib.mkBefore [
              "systemctl --user stop graphical-session.target"
              "systemctl --user start hyprland-session.target"
            ];

            variables = [ "--all" ];
          };
          xwayland.enable =
            if hostname != "zion"
            then true
            else false;
          plugins = [
            inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
          ];
        };
      };
    };
    home = {
      sessionVariables = {
        POLKIT_AUTH_AGENT = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";

        # "LIBVA_DRIVE_NAME" = if (hostname != "zion" || "air") then "nvidia" else "iHD";
        "LIBVA_DRIVE_NAME" = "nvidia";
        "GBM_BACKEND" = "nvidia-drm";
        # "GBM_BACKEND" = if (hostname == "nitro") then "nvidia-drm" else "";
        # "__GLX_VENDOR_LIBRARY" = if (hostname == "nitro" || "rocinante") then "nvidia" else "";
        "__GLX_VENDOR_LIBRARY" = "nvidia";
        "WLR_RENDERER_ALLOW_SOFTWARE" = "1";
        "WLR_NO_HARDWARE_CURSORS" = "1";
        "__GL_GSYNC_ALLOWED" = "0";
        "__GL_VRR_ALLOWED" = "0";
        # "MOZ_DISABLE_RDD_SANDBOX" = "1";
        "disable_features" = "WaylandOverlayDelegation";
        "enable_features" = "WaylandWindowDecorations";
        "ozone_platform" = "wayland";
        "ozone_platform_hint" = "auto";
        "LIBSEAT_BACKEND" = "logind";

        # WEBKIT_DISABLE_COMPOSITING_MODE = 1;

        # nitro
        "VAAPI_MPEG4_ENABLED" = "true";
        "VDPAU_DRIVER" = "nvidia";
        "GST_PLUGIN_FEATURE_RANK" = "nvmpegvideodec:MAX,nvmpeg2videodec:MAX,nvmpeg4videodec:MAX,nvh264sldec:MAX,nvh264dec:MAX,nvjpegdec:MAX,nvh265sldec:MAX,nvh265dec:MAX,nvvp9dec:MAX";
        "GST_VAAPI_ALL_DRIVERS" = "1";

        # Gaming Parameters
        ##
        "__GL_SHADER_CACHE" = "1";
        "__GL_SHADER_DISK_CACHE" = "1";
        "__GL_SHADER_DISK_CACHE_SKIP_CLEANUP" = "1";
        "__GL_ExperimentalPerfStrategy" = "1";
        "DXVK_ENABLE_NVAPI" = "1";
        "ENABLE_VKBASALT" = "0";

        ##PIPEWIRE_LATENCY=1024/44100
        "PULSE_LATENCY_MSEC" = "60";

        # Proton Settings
        ##
        "PROTON_ENABLE_NGX_UPDATER" = "1";
        "PROTON_ENABLE_NVAPI" = "1";
        "PROTON_FORCE_LARGE_ADDRESS_AWARE" = "1";
        "PROTON_HIDE_NVIDIA_GPU" = "0";
        "STEAM_FORCE_DESKTOPUI_SCALING" = "1.25";
        "VKD3D_CONFIG" = "dxr";

        # Display Environment
        ##
        "CLUTTER_BACKEND" = "wayland";
        "CLUTTER_DEFAULT_FPS" = "60";
        "GDK_BACKEND" = "wayland,x11";
        "XDG_CURRENT_DESKTOP" = "Hyprland";
        "XDG_SESSION_DESKTOP" = "Hyprland";

        # increase priority
        QT_STYLE_OVERRIDE = lib.mkForce "kvantum";
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        # "QT_AUTO_SCREEN_SCALE_FACTOR" = "0";
        QT_QPA_PLATFORM = "wayland;xcb";
        # "QT_QPA_PLATFORM" = "wayland";
        # "QT_QPA_PLATFORMTHEME" = "qt5ct";
        QT_QPA_PLATFORMTHEME = lib.mkForce "qtct";
        # remain backwards compatible with qt5
        DISABLE_QT_COMPAT = "0";

        # Input method framework
        # GTK_IM_MODULE = "fcitx";
        # "GTK_IM_MODULE" = "ibus";
        # QT_IM_MODULE = "fcitx";
        # "QT_IM_MODULE" = "ibus";
        # XMODIFIERS = "@im=fcitx";
        # "XMODIFIERS" = "@im=ibus";
        # DefaultIMModule = "fcitx";
        # SDL_IM_MODULE = "fcitx";
        # GLFW_IM_MODULE = "ibus";
      };
    };

    nix.settings = {
      substituters = [
        "https://nixpkgs-wayland.cachix.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };
}
# systemd = {
#   user.services.polkit-gnome-authentication-agent-1 = {
#     description = "polkit-gnome-authentication-agent-1";
#     wantedBy = [ "graphical-session.target" ];
#     wants = [ "graphical-session.target" ];
#     after = [ "graphical-session.target" ];
#     serviceConfig = {
#       Type = "simple";
#       ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
#       Restart = "on-failure";
#       RestartSec = 1;
#       TimeoutStopSec = 10;
#     };
#   };
# };
# systemd = {
#   user.services.polkit-kde-authentication-agent-1 = {
#     # after = [ "graphical-session.target" ];
#     after = [ "NetworkManager.target" ];
#     description = "polkit-kde-authentication-agent-1";
#     wantedBy = [ "graphical-session.target" ];
#     # wants = [ "graphical-session.target" ];
#     wants = [ "NetworkManager.target" ];
#     serviceConfig = {
#       Type = "simple";
#       ExecStart = "${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
#       Restart = "on-failure";
#       RestartSec = 1;
#       TimeoutStopSec = 10;
#     };
#   };
# };
