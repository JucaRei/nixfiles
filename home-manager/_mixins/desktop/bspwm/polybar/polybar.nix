{ pkgs, ... }: {
  imports = [
    # ./scripts.nix
  ];
  services = {
    polybar = {
      enable = true;
      package = pkgs.polybarFull;
      # package = pkgs.override.polybar {
      # Extra Packages
      # alsaSupport = true;
      # pulseSupport = true;
      # };
      script = "polybar tokyodark &";

      # script = ''
      #   #!/usr/bin/env bash

      #   killall -q polybar && sleep 2

      #   echo "---" | tee -a /tmp/polybar1.log

      #   polybar tokyodark 2>&1 | tee -a /tmp/polybar1.log &
      #   disown

      #   echo "Bar launched..."
      # '';
      config = ./test/config.ini;
    };
  };
}
