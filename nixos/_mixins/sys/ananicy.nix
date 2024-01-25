{ pkgs, ... }: {
  services = {
    # Auto Nice Daemon
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
    };
  };
}
