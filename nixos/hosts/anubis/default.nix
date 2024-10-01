{ ... }: {
  services = {
    clight = {
      enable = true;
      settings = {
        verbose = true;
        backlight.disabled = false;
        dpms.timeouts = [ 900 300 ];
        dimmer.timeouts = [ 870 270 ];
        gamma.long_transitions = true;
        screen.disabled = true;
      };
    };
  };
}
