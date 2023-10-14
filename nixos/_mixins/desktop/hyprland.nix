{ pkgs, username, lib, ... }: {
  programs = lib.mkDefault {
    hyprland = {
      enable = true;
      nvidiaPatches = true;
      xwayland = {
        enable = true;
      };
    };
  };

  services = {
    # getty = {
    #   autologinUser = "${username}";
    # };
    xserver = {
      enable = true;
      xkbVariant = "nodeadkeys";
      displayManager = {
        lightdm.enable = true;
        lightdm.greeters.gtk = {
          enable = true;
          cursorTheme.name = "Yaru";
          cursorTheme.package = pkgs.yaru-theme;
          cursorTheme.size = 24;
          iconTheme.name = lib.mkDefault "Yaru-magenta-dark";
          iconTheme.package = pkgs.yaru-theme;
          theme.name = lib.mkDefault "Yaru-magenta-dark";
          theme.package = pkgs.yaru-theme;
          indicators = [
            "~session"
            "~host"
            "~spacer"
            "~clock"
            "~spacer"
            "~a11y"
            "~power"
          ];
          # https://github.com/Xubuntu/lightdm-gtk-greeter/blob/master/data/lightdm-gtk-greeter.conf
          extraConfig = ''
            # background = Background file to use, either an image path or a color (e.g. #772953)
            font-name = Work Sans 12
            xft-antialias = true
            xft-dpi = 96
            xft-hintstyle = slight
            xft-rgba = rgb

            active-monitor = #cursor
            # position = x y ("50% 50%" by default)  Login window position
            # default-user-image = Image used as default user icon, path or #icon-name
            hide-user-image = false
            round-user-image = false
            highlight-logged-user = true
            panel-position = top
            clock-format = %a, %b %d  %H:%M
          '';
        };
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      ### Bars
      # eww 
      (waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [
          "-Dexperimental=true"
        ];
      }))

      ### Notification daemon
      dunst
      libnotify

      ### Wallpaper Daemon
      swww
      # hyprpaper
      # swaybg
      # wpaperd
      # mpvpaer

      ### Terminals
      kitty
      # alacritty
      # wezterm
      # st

      ### App launcher
      rofi-wayland
      # wofi # gtk rofi
      # bemenu
      # fuzzel
      # toffi

      ranger
      ueberzug
      picom
      rofi
      dolphin
      qutebrowser
      light
      shotman
    ];

    sessionVariables = {

      WLR_NO_HARDWARE_CURSORS = "1"; # If your cursor becomes invisible
      NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
    };
  };

  security = {
    pam.services = {
      # swaylock = { };
      gtklock = { };
      login.enableGnomeKeyring = true;
    };
  };

  hardware = lib.mkForce {
    opengl.enable = true; #Opengl
    nvidia.modesetting.enable = true; # Most wayland compositors need this
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # provides a XDG Portals implementation.
    ];
  };
}
