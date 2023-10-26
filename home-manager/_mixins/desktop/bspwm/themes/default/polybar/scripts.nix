{ config, ... }: {
  home = {
    file = {
      ".local/polybar/scripts" = {
        source = ../../../../../config/polybar-scripts;
        executable = true;
        recursive = true;
      };
      # ".config/polybar/scripts".source = builtins.path {
      #   path = ./scripts;
      #   executable = true;
      #   recursive = true;
      # };
    };
    #   ".config/polybar/scripts/bluetooth.sh" = {
    #     executable = true;
    #     text = ''
    #       #!/bin/sh

    #       device="~/.config/.config/polybar/scripts/teste.sh"

    #       if [ $(bluetoothctl show | grep "Powered: yes" | wc -c) -eq 0 ]; then
    #         echo "%{F#66ffffff}"
    #       else
    #         if [ $(echo info | bluetoothctl | grep 'Device' | wc -c) -eq 0 ]; then
    #           echo ""
    #           #echo "  "
    #         #else
    #       	#if [ $(bluetoothctl show | grep "Connected: yes" | wc -c) -eq 0 ]; then
    #       	# $(device)
    #       	#fi
    #         fi
    #         echo "%{F#2193ff}"
    #       fi
    #     '';
    #   };
    #   ".config/polybar/scripts/memory" = {
    #     executable = true;
    #     text = ''
    #       free -m | sed -n 's/^Mem:\s\+[0-9]\+\s\+\([0-9]\+\)\s.\+/\1/p'
    #     '';
    #   };
    # };
  };
}

# xdg = {
#     configFile = {
#       "polybar/scripts/bluetooth" = {
#         source = ./scripts/bluetooth;
#         executable = true;
#         # recursive = true;
#       };
