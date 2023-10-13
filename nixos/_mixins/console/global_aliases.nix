{ pkgs, ... }: {
  environment = {
    # interactiveShellInit = ''''
    shellAliases = {
      nix-gc = "sudo nix-collect-garbage --delete-older-than 4d && nix-collect-garbage --delete-older-than 4d";
      # rebuild-all = "sudo nixos-rebuild switch --flake $HOME/Zero/nixfiles && home-manager switch -b backup --flake $HOME/Zero/nixfiles";
      rebuild-all = "sudo nixos-rebuild switch --flake $HOME/.dotfiles && systemd-run --no-ask-password --uid=1000 --user --scope -p MemoryLimit=4000M -p CPUQuota=60% home-manager switch -b backup --flake $HOME/.dotfiles";
      rebuild-host = "sudo nixos-rebuild switch --flake $HOME/.dotfiles";
      rebuild-boot = "sudo nixos-rebuild boot --flake $HOME/.dotfiles";
      rebuild-iso-console = "sudo true && pushd $HOME/.dotfiles && nix build .#nixosConfigurations.iso-console.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-console/nixos.iso && popd";
      rebuild-iso-desktop = "sudo true && pushd $HOME/.dotfiles && nix build .#nixosConfigurations.iso-desktop.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-desktop/nixos.iso && popd";
      rebuild-iso-gpd-edp = "sudo true && pushd $HOME/.dotfiles && nix build .#nixosConfigurations.iso-gpd-edp.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-gpd-edp.iso && popd";
      rebuild-iso-gpd-dsi = "sudo true && pushd $HOME/.dotfiles && nix build .#nixosConfigurations.iso-gpd-dsi.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-gpd-dsi.iso && popd";
      "du" = "${pkgs.ncdu_1}/bin/ncdu --color dark -r -x --exclude .git --exclude .svn --exclude .asdf --exclude node_modules --exclude .npm --exclude .nuget --exclude Library";
      sxorg = "export DISPLAY=:0.0";
      drivers = "lspci -v | grep -B8 -v 'Kernel modules: [a-z0-9]+'";
    };
  };
}

