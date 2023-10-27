{ config, pkgs, ... }: {
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

      ".local/polybar/scripts/pipewire.sh" = {
        executable = true;

        text = ''
          #!${pkgs.bash}/bin/bash

          getDefaultSink() {
            defaultSink=$(${pkgs.pulseaudio}/bin/pactl info | ${pkgs.gawk}/bin/awk -F : '/Default Sink:/{print $2}')
            description=$(${pkgs.pulseaudio}/bin/pactl list sinks | ${pkgs.gnused}/bin/sed -n "/''${defaultSink}/,/Description/p; /Description/q" | ${pkgs.gnused}/bin/sed -n 's/^.*Description: \(.*\)$/\1/p')
            echo "''${description}"
          }

          getDefaultSource() {
            defaultSource=$(${pkgs.pulseaudio}/bin/pactl info | ${pkgs.gawk}/bin/awk -F : '/Default Source:/{print $2}')
            description=$(${pkgs.pulseaudio}/bin/pactl list sources | ${pkgs.gnused}/bin/sed -n "/''${defaultSource}/,/Description/p; /Description/q" | ${pkgs.gnused}/bin/sed -n 's/^.*Description: \(.*\)$/\1/p')
            echo "''${description}"
          }

          function main() {
              DEFAULT_SOURCE=$(getDefaultSource)
              DEFAULT_SINK=$(getDefaultSink)
              VOLUME=$(${pkgs.pulseaudio}/bin/pactl list sinks | ${pkgs.gnused}/bin/sed -n "/Sink #''${DEFAULT_SINK_ID}/,/Volume/ s!^[[:space:]]\+Volume:.* \([[:digit:]]\+\)%.*!\1!p" | ${pkgs.coreutils}/bin/head -n1)
              IS_MUTED=$(${pkgs.pulseaudio}/bin/pactl list sinks | ${pkgs.gnused}/bin/sed -n "/Sink #''${DEFAULT_SINK_ID}/,/Mute/ s/Mute: \(yes\)/\1/p")

              action=$1
              if [ "''${action}" == "up" ]; then
                  ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%
              elif [ "''${action}" == "down" ]; then
                  ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%
              elif [ "''${action}" == "mute" ]; then
                  ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle
              else
                  if [ "''${IS_MUTED}" != "" ]; then
                      echo " ''${DEFAULT_SOURCE} | ﱝ ''${VOLUME}% ''${DEFAULT_SINK}"
                  else
                      echo " ''${DEFAULT_SOURCE} | 墳 ''${VOLUME}% ''${DEFAULT_SINK}"
                  fi
              fi
          }

          main "$@"

        '';
      };
    };
  };
}

# xdg = {
#     configFile = {
#       "polybar/scripts/bluetooth" = {
#         source = ./scripts/bluetooth;
#         executable = true;
#         # recursive = true;
#       };
