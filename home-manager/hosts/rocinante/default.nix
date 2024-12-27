{ config, ... }: {
  config = {
    desktop.apps = {
      video = {
        mpv = { enable = true; };
      };
    };
  };
}
