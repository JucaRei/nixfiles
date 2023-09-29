{ config, desktop, lib, pkgs, username, ... }: {
  imports = [
    ../../_mixins/apps/browser/firefox.nix
    ../../_mixins/apps/text-editor/vscode.nix
  ];
  config.environment.systemPackages = with pkgs; [
    gparted
  ];
  config.systemd.tmpfiles.rules = [
    "d /home/${username}/Desktop 0755 ${username} users"
    "L+ /home/${username}/Desktop/gparted.desktop - - - - ${pkgs.gparted}/share/applications/gparted.desktop"
    "L+ /home/${username}/Desktop/io.elementary.terminal.desktop - - - - ${pkgs.pantheon.elementary-terminal}/share/applications/io.elementary.terminal.desktop"
    "L+ /home/${username}/Desktop/io.calamares.calamares.desktop - - - - ${pkgs.calamares-nixos}/share/applications/io.calamares.calamares.desktop"
  ];
  config = {
    isoImage.edition = lib.mkForce "${desktop}";
    services = {
      xserver = {
        displayManager.autoLogin.user = "${username}";
        libinput = {
          enable = true;
          touchpad = {
            # horizontalScrolling = true;
            naturalScrolling = false;
            tapping = true;
            tappingDragLock = false;
          };
        };
      };
      kmscon.autologinUser = lib.mkForce null;
    };
  };

  #environment.variables = {
  #  # Firefox fixes
  #  MOZ_X11_EGL = "1";
  #  MOZ_USE_XINPUT2 = "1";
  #  MOZ_DISABLE_RDD_SANDBOX = "1";

  #  # SDL Soundfont
  #  SDL_SOUNDFONTS = LT.constants.soundfontPath pkgs;

  #  # Webkit2gtk fixes
  #  WEBKIT_DISABLE_COMPOSITING_MODE = "1";
  #};
}
