{ pkgs, ... }: {
  environment = {
    shellAliases = {
      nix-gc-4d = "sudo nix-collect-garbage --delete-older-than 4d && nix-collect-garbage --delete-older-than 4d";
      system-clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      # rebuild-all = "sudo nixos-rebuild switch --flake $HOME/Zero/nixfiles && home-manager switch -b backup --flake $HOME/Zero/nixfiles";
      rebuild-all = "sudo nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles && systemd-run --no-ask-password --uid=1000 --user --scope -p MemoryLimit=4000M -p CPUQuota=60% home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles";
      rebuild-host = "sudo nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles --show-trace";
      rebuild-boot = "sudo nixos-rebuild boot --flake $HOME/.dotfiles/nixfiles --show-trace";
      dotsync = "pushd $HOME/.dotfiles/nixfiles && git pull && popd";
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

    };
  };
}
