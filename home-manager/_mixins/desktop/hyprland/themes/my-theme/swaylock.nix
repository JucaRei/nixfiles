{ pkgs, ... }: {
  programs = {
    swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        ignore-empy-password = ''
          font = "Fira Sans Semibold";
        '';
        clock = ''
          timestr = "%R";
          datestr = "%a, %e of %B";
        '';
        screenshots = ''
          fade-in = 1;
          effect-blur = "5x2";
        '';
        indicator = ''
          indicator-radius = 200;
          indicator-thickness = 20;
        '';
        indicator-caps-lock = ''
          key-hl-color = "00000066";
          separator-color = "00000000";

          inside-color = "00000033";
          inside-clear-color = "ffffff00";
          inside-caps-lock-color = "ffffff00";
          inside-ver-color = "ffffff00";
          inside-wrong-color = "ffffff00";

          ring-color = "ffffff";
          ring-clear-color = "ffffff";
          ring-caps-lock-color = "ffffff";
          ring-ver-color = "ffffff";
          ring-wrong-color = "ffffff";

          line-color = "00000000";
          line-clear-color = "ffffffFF";
          line-caps-lock-color = "ffffffFF";
          line-ver-color = "ffffffFF";
          line-wrong-color = "ffffffFF";

          text-color = "ffffff";
          text-clear-color = "ffffff";
          text-ver-color = "ffffff";
          text-wrong-color = "ffffff";

          bs-hl-color = "ffffff";
          caps-lock-key-hl-color = "ffffffFF";
          caps-lock-bs-hl-color = "ffffffFF";
        '';
        disable-caps-lock-text = ''
          text-caps-lock-color = "ffffff";
        '';
      };
    };
  };
}
