{ config, lib, ... }: {
  xdg = {
    enable = true;
    configHome = config.home.homeDirectory + "/.config";
    cacheHome = config.home.homeDirectory + "/.local/cache";
    dataHome = config.home.homeDirectory + "/.local/share";
    stateHome = config.home.homeDirectory + "/.local/state";

    userDirs = {
      enable = true;
      createDirectories = lib.mkDefault true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR =
          "${config.home.homeDirectory}/Pictures/Screenshots";
      };
    };
  };
}

