{ pkgs, lib, ... }:
{
  # Adjust the color temperature(& brightness) of your screen according to
  # your surroundings. This may help your eyes hurt less if you are
  # working in front of the screen at night.
  #
  # works fine with both x11 & wayland(hyprland)
  #
  # https://gitlab.com/chinstrap/gammastep
  # services.gammastep = {
  #   enable = true;
  #   # add a gammastep icon in the system tray
  #   # has problem with wayland, so disable it
  #   tray = true;
  #   temperature = {
  #     day = 5700;
  #     night = 4000;
  #   };
  #   # https://gitlab.com/chinstrap/gammastep/-/blob/master/gammastep.conf.sample?ref_type=heads
  #   settings = {
  #     general = {
  #       fade = "1"; # gradually apply the new screen temperature/brightness over a couple of seconds.
  #       # it is a fake brightness adjustment obtained by manipulating the gamma ramps,
  #       # which means that it does not reduce the backlight　of the screen.
  #       # Preferably only use it if your normal backlight adjustment is too coarse-grained.
  #       brightness-day = "1.0";
  #       brightness-night = "0.8";
  #       location-provider = "manual";

  #       # by default, Redshift will use the current elevation of the sun
  #       # to determine whether it is daytime, night or in transition (dawn/dusk).
  #       # dawn-time = "6:00-8:45";
  #       # dusk-time = "18:35-20:15";
  #     };
  #     manual = {
  #       # Brazil, SP
  #       lat = -23.539380;
  #       lon = -46.652530;
  #     };
  #   };
  # };

  services = {
    wlsunset = {
      enable = true;
      latitude = "-23.539380";
      longitude = "-46.652530";
      gamma = "0.9";
      temperature = {
        day = 6500;
        night = 4200;
      };
    };
  };
}
