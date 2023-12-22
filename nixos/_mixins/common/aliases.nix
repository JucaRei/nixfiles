{ pkgs, ... }: {
  environment = {
    shellAliases =
      let
        shebang = "#!${pkgs.bash}/bin/bash";

        ensure-binary-exists = bin: ''
          if ! command -v ${bin} > /dev/null; then
            ${pkgs.xorg.xmessage}/bin/xmessage "'${bin}' not found"
            exit 1
          fi
        '';

        ensure-env-var = var:
          let v = "$" + "${var}"; in
          ''
            [ -z "${v}" ] && echo "${var} is not set" && exit 1
          '';
      in
      {
        nix-gc-4d = "sudo nix-collect-garbage --delete-older-than 4d && nix-collect-garbage --delete-older-than 4d";
        system-clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
        # rebuild-all = "sudo nixos-rebuild switch --flake $HOME/Zero/nixfiles && home-manager switch -b backup --flake $HOME/Zero/nixfiles";
        rebuild-all = "sudo nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles && systemd-run --no-ask-password --uid=1000 --user --scope -p MemoryLimit=4000M -p CPUQuota=60% home-manager switch -b backup --impure --flake $HOME/.dotfiles/nixfiles";
        rebuild-host = "sudo nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles --show-trace";
        rebuild-boot = "sudo nixos-rebuild boot --flake $HOME/.dotfiles/nixfiles --show-trace";
        dotsync = "pushd $HOME/.dotfiles/nixfiles && git pull && popd";
        upgrade = "sudo nixos-rebuild --upgrade-all switch";
        undo-build = "sudo nixos-rebuild --rollback";
        rebuild-iso-console = "sudo true && pushd $HOME/.dotfiles/nixfiles && nix build .#nixosConfigurations.iso-console.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-console/nixos.iso && popd";
        rebuild-iso-desktop = "sudo true && pushd $HOME/.dotfiles/nixfiles && nix build .#nixosConfigurations.iso-desktop.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-desktop/nixos.iso && popd";
        rebuild-iso-gpd-edp = "sudo true && pushd $HOME/.dotfiles/nixfiles && nix build .#nixosConfigurations.iso-gpd-edp.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-gpd-edp.iso && popd";
        rebuild-iso-gpd-dsi = "sudo true && pushd $HOME/.dotfiles/nixfiles && nix build .#nixosConfigurations.iso-gpd-dsi.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-gpd-dsi.iso && popd";
        "du" = "${pkgs.ncdu_1}/bin/ncdu --color dark -r -x --exclude .git --exclude .svn --exclude .asdf --exclude node_modules --exclude .npm --exclude .nuget --exclude Library";
        sxorg = "export DISPLAY=:0.0";
        drivers = "lspci -v | grep -B8 -v 'Kernel modules: [a-z0-9]+'";

        ### fs
        r = "rsync -ra --info=progress2";
        u = "aunpack"; # one tool to unpack them all
        fd = "fd --hidden --exclude .git";
        search = "nix search nixpkgs";

        ### NIX
        inspect-store = "nix path-info -rSh /run/current-system | sort -k2h ";
        # wipe-user-packages = "nix-env -e '*'";

        ### Privacy
        tor = "nix-shell -p tor-browser-bundle-bin --run tor-browser";

        ### vnc
        # grab-display = "set DISPLAY ':0.0'";
        # vnc-server = "x11vnc -repeat -forever -noxrecord -noxdamage -rfbport 5900";
        # vnc = "vncviewer −FullscreenSystemKeys -MenuKey F12";

        tailup = "sudo tailscale up --accept-routes --accept-dns=false";
        taildown = "sudo tailscale down";

        # Print timestamp along with cmd output
        # Example: cmd | ts
        ts = "gawk '{ print strftime(\"[%Y-%m-%d %H:%M:%S]\"), $0 }'";

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
  };
}
