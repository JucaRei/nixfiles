{ pkgs, username, ... }: {
  programs = {
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
      ranger
      ueberzug
      waybar
      dunst
      libnotify
      kitty
      picom
      rofi
      swww
      dolphin
      qutebrowser
      light
      shotman
    ];

    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };
  };

  security = {
    pam.services.swaylock = { };
  };
}
