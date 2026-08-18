_: {
  config = {
    services.chrony = {
      enable = true;
      initstepslew = {
        enabled = true;
        threshold = 100;
      };
      extraConfig = ''
        makestep 1 -1
      '';
      servers = [
        "time.cloudflare.com"
        "time.google.com"
        "0.pool.ntp.org"
        "1.pool.ntp.org"
        "2.pool.ntp.org"
        "3.pool.ntp.org"
      ];
    };
  };
}
