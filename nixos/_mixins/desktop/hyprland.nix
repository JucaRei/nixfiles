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
    dbus = {
      enable = true;
      # Make the gnome keyring work properly
      packages = [ pkgs.gnome3.gnome-keyring pkgs.gcr ];
    };

    gnome = {
      gnome-keyring.enable = true;
      sushi.enable = true;
    };

    greetd = {
      enable = true;
      restart = false;
      settings = {
        default_session = {
          command = ''
            ${lib.makeBinPath [pkgs.greetd.tuigreet]}/tuigreet -r --asterisks --time \
              --cmd ${runner}
          '';
        };
      };
    };

    gvfs.enable = true;
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

      polkit_gnome
      gnome.zenity
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
