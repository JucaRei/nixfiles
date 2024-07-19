{ pkgs, lib, ... }: {
  users.users.kodi = {
    isNormalUser = true;
    extraGroups = [ "video" ];
    description = "Kodi Media Center";
    hashedPassword = "$6$A5gukqBVeM3eJblr$K6L1kxSDvJJjy6.LVx78d1QojtmGJBwpI3MPvc52h8H/Avg0KQW/uG6QazLiuoC2vGZ79nq3czvj96hEdSLUf1";
  };
  services = {
    # disable greetd, as cage starts directly
    # greetd.enable = lib.mkForce false;
    xserver = {
      enable = true;
      desktopManager.kodi = {
        enable = true;
        package = pkgs.kodi.withPackages (p: with p; [
          # kodi-platform
          youtube
          inputstream-adaptive
          # vfs-sftp
          sponsorblock
          # invidious
          # joystick
          sendtokodi
        ]);
      };
      displayManager = {
        autoLogin = {
          enable = true;
          user = lib.mkForce "kodi";
        };

        #disable blank screen
        setupCommands = ''
          /run/current-system/sw/bin/xset -dpms
          /run/current-system/sw/bin/xset s off
        '';

        # This may be needed to force Lightdm into 'autologin' mode.
        # Setting an integer for the amount of time lightdm will wait
        # between attempts to try to autologin again.
        # lightdm.autoLogin.timeout = 3;
      };
    };

    # cage is compositor and "login manager" that starts a single program: Kodi
    # cage = {
    #   enable = true;
    #   user = "kodi";
    #   program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
    #   environment = {
    #     # TODO does this suppport layout switching? try out
    #     # XKB_DEFAULT_LAYOUT = "br,en";
    #     XKB_DEFAULT_LAYOUT = "br";
    #     # XKB_DEFAULT_VARIANT = "abnt2,nodeadkeys";
    #     XKB_DEFAULT_VARIANT = "abnt2";
    #     XKB_DEFAULT_OPTIONS = "grp:ctrls_toggle";
    #   };
    # };
  };
  networking.firewall = {
    allowedTCPPorts = [ 8080 ]; # for web interface / remote control
    allowedUDPPorts = [ 8080 ];
  };
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  # environment.systemPackages = with pkgs; [
  #   # for manual usage if needed
  #   pkgs.cage
  #   pkgs.kodi-wayland
  # ];
  nixpkgs.config.kodi.enableAdvancedLauncher = true;
  sound.enable = true;
}
