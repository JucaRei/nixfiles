{ pkgs, username, lib, ... }: {
  programs = lib.mkDefault {
    hyprland = {
      enable = true;
      nvidiaPatches = true;
      xwayland.enable = true;
    };
  };

  services = {
    getty = {
      autologinUser = "${username}";
    };
    xserver = {
      xkbVariant = "nodeadkeys";
      displayManager = {
        autoLogin = {
          enable = false;
          user = "${username}";
        };
      };
    };
    greetd = {
      enable = true;
      settings = {
        default_session.command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time \
          --asterisks \
          --user-menu \
          --cmd Hyprland
        '';
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
    pam.services.swaylock = { };
  };

  hardware = lib.mkForce {
    opengl.enable = true; #Opengl
    nvidia.modesetting.enable = true; # Most wayland compositors need this
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [ xgd-desktop-portal-gtk ];
    };
  };
}
