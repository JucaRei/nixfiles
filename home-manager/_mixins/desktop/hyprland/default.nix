{ pkgs, lib, config, inputs, hostname, ... }:
let
  nvidiaEnabled = (lib.elem "nvidia" config.services.xserver.videoDrivers);
in
{
  imports = [
    ./themes/my-theme
  ];
  home = {
    packages = with pkgs; [
      kitty # terminal
      # mako # notification daemon
      libsForQt5.polkit-kde-agent # polkit agent
      qalculate-gtk
      # swaylock-effects
      bibata-cursors
      lxqt.pavucontrol-qt
      nwg-look
    ];
  };
  wayland =
    {
      windowManager = {
        hyprland = {
          # enable = if hostname != "zion" then true else false;
          enable = true;
          # Check if it has nvidia and nvidia Driver installed
          # enableNvidiaPatches = if nvidiaEnabled != true then false else true;
          # enableNvidiaPatches = true;
          package = inputs.hyprland.packages.${pkgs.system}.hyprland.override {
            enableXWayland = true; # whether to enable XWayland
            legacyRenderer = if hostname == "nitro" then false else true; # false; # whether to use the legacy renderer (for old GPUs)
            withSystemd = if hostname == "nitro" then true else false; # whether to build with systemd support
          };
          # extraConfig = '''';
          # finalPackage = '''';
          # plugins = [];
          # settings = {};
          systemd =
            {
              enable =
                if hostname != "zion" then true else false;
              # extraCommands = "";
              # variable = [];
            };
          xwayland.enable = if hostname != "zion" then true else false;
        };
      };
    };
  home = {
    sessionVariables = {
      "LIBVA_DRIVE_NAME" = if (hostname != "zion" || "air") then "nvidia" else "iHD";
      "XDG_SESSION_TYPE" = "wayland";
      "GBM_BACKEND" = if (hostname == "nitro") then "nvidia-drm" else "";
      "__GLX_VENDOR_LIBRARY" = if (hostname == "nitro" || "rocinante") then "nvidia" else "";
      "WLR_RENDERER_ALLOW_SOFTWARE" = "1";
      "WLR_NO_HARDWARE_CURSORS" = "1";
      "__GL_GSYNC_ALLOWED" = "0";
      "__GL_VRR_ALLOWED" = "0";
      "QT_QPA_PLATFORM" = "wayland";
      # "MOZ_DISABLE_RDD_SANDBOX" = "1";
      "MOZ_ENABLE_WAYLAND" = "1";

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
      "GDK_BACKEND" = "wayland";
      "GTK_IM_MODULE" = "ibus";
      "KITTY_ENABLE_WAYLAND" = "1";
      "QT_AUTO_SCREEN_SCALE_FACTOR" = "0";
      "QT_IM_MODULE" = "ibus";
      "QT_QPA_PLATFORMTHEME" = "qt5ct";
      "SDL_VIDEODRIVER" = "wayland";
      "XCURSOR_THEME" = "Adwaita";
      "XCURSOR_SIZE" = "24";
      "XMODIFIERS" = "@im=ibus";
    };
  };
}
