_: {
  xdg = {
    configFile = {
      "polybar/scripts/bluetooth" = {
        source = ./scripts/bluetooth;
        executable = true;
        # recursive = true;
      };
      "polybar/scripts/gamemode" = {
        source = ./scripts/gamemode;
        executable = true;
      };
      "polybar/scripts/get-spotify-status" = {
        source = ./scripts/get-spotify-status;
        executable = true;
      };
      "polybar/scripts/github" = {
        source = ./scripts/github;
        executable = true;
      };
      "polybar/scripts/microphone" = {
        source = ./scripts/microphone;
        executable = true;
      };
      "polybar/scripts/scroll-spotify" = {
        source = ./scripts/scroll-spotify;
        executable = true;
      };
      "polybar/scripts/toggle-bluetooth" = {
        source = ./scripts/toggle-bluetooth;
        executable = true;
      };
      "polybar/scripts/bluetooth.sh" = {
        executable = true;
        text = ''
          #!/bin/sh

          device="~/.config/polybar/scripts/teste.sh"

          if [ $(bluetoothctl show | grep "Powered: yes" | wc -c) -eq 0 ]; then
            echo "%{F#66ffffff}"
          else
            if [ $(echo info | bluetoothctl | grep 'Device' | wc -c) -eq 0 ]; then
              echo ""
              #echo "  "
            #else
          	#if [ $(bluetoothctl show | grep "Connected: yes" | wc -c) -eq 0 ]; then
          	# $(device)
          	#fi
            fi
            echo "%{F#2193ff}"
          fi
        '';
      };
      "polybar/scripts/tray" = {
        source = ./scripts/tray;
        executable = true;
      };
      "polybar/scripts/tray-status" = {
        source = ./scripts/tray-status;
        executable = true;
      };
      "polybar/scripts/updates" = {
        source = ./scripts/updates;
        executable = true;
      };
      "polybar/scripts/bluetooth_battery.sh" = {
        source = ./scripts/bluetooth_battery.sh;
        executable = true;
      };
      "polybar/scripts/mic.sh" = {
        source = ./scripts/mic.sh;
        executable = true;
      };
      "polybar/scripts/spotify.sh" = {
        source = ./scripts/spotify.sh;
        executable = true;
      };
      "polybar/scripts/polywins" = {
        source = ./scripts/polywins;
        executable = true;
      };
      "polybar/scripts/nix-updates" = {
        source = ./scripts/nix-updates;
        executable = true;
      };
      "polybar/scripts/disks" = {
        source = ./scripts/disks;
        executable = true;
      };
      "polybar/scripts/memory" = {
        executable = true;
        text = ''
          free -m | sed -n 's/^Mem:\s\+[0-9]\+\s\+\([0-9]\+\)\s.\+/\1/p'
        '';
      };
    };
  };
}
