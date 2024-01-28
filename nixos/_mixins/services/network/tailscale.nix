{ pkgs, config, ... }: {
  services.tailscale.enable = true;
  networking = {
    firewall = {
      checkReversePath = "loose";
      allowedUDPPorts = [ config.services.tailscale.port ];
      trustedInterfaces = [ "tailscale0" ];
    };
  };

  environment.shellAliases = let
    shebang = "#!${pkgs.bash}/bin/bash";

    ensure-binary-exists = bin: ''
      if ! command -v ${bin} > /dev/null; then
        ${pkgs.xorg.xmessage}/bin/xmessage "'${bin}' not found"
        exit 1
      fi
    '';

    ensure-env-var = var:
      let v = "$" + "${var}";
      in ''
        [ -z "${v}" ] && echo "${var} is not set" && exit 1
      '';
  in {
    tailscale-ip = ''
      ${shebang}
      # Get the current tailscale ip if tailscale is up
      set -euo pipefail
      isOnline=$(tailscale status --json | jq -r '.Self.Online')
      if [[ "$isOnline" == "true" ]]; then
        tailscaleIp=$(tailscale status --json | jq -r '.Self.TailscaleIPs[0]')
        echo "$tailscaleIp"
      fi
    '';

    dlfile = ''
      ${shebang}
      # Provides the ability to download a file by dropping it into a window

      url=$(${pkgs.dragon} -t -x)

      if [ -n "$url" ]; then
        printf "File Name: "
        name=""
        while [ -z $name ] || [ -e $name ]
        do
          read -r name
          if [ -e "$name" ]; then
            printf "File already exists, overwrite (y|n): "
            read -r ans

            if [ "$ans" = "y" ]; then
              break
            else
              printf "File Name: "
            fi
          fi
        done

        # Download the file with curl
        [ -n "$name" ] && curl -o "$name" "$url" || exit 1
      else
        exit 1
      fi
    '';
    nixos = ''
      ${shebang}
      usage() {
          cat <<EOF
      Run nixos commands
      Usage:
        -b, --build, b, build:      Build nixos configuration
        -s, --switch, s, switch:    Build nixos configuration and switch to it
        -h, --help, h, help:        This help message
      EOF
      }
      ${ensure-env-var "NIXOS_CONFIG"}
      build() {
          sudo nixos-rebuild test --flake "$NIXOS_CONFIG#" --impure
      }
      switch() {
          sudo nixos-rebuild switch --flake "$NIXOS_CONFIG#" --impure
      }
      case "$1" in
          -b | --build | b | build)
              build
              ;;
          -s |--switch | s | switch)
              switch
              ;;
          -h | --help | h | help)
              usage
              ;;
          *)
              usage
              exit 1
              ;;
      esac
    '';
  };
}
