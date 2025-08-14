{ config, inputs, pkgs, lib, isInstall, stateVersion, ... }:
let
  currentDir = ./.; # Represents the current directory
  isDirectoryAndNotTemplate = name: type: type == "directory";
  directories = lib.filterAttrs isDirectoryAndNotTemplate (builtins.readDir currentDir);
  importDirectory = name: import (currentDir + "/${name}");
in
{
  imports = lib.mapAttrsToList (name: _: importDirectory name) directories ++ [
    inputs.nur.modules.nixos.default
    inputs.nixosModules.disko
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.auto-cpufreq.nixosModules.default
    inputs.catppuccin.nixosModules.catppuccin
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.nix-index-database.nixosModules.nix-index
    inputs.chaotic.nixosModules.default
    inputs.sops-nix.nixosModules.sops
  ];

  system = {
    nixos.label = lib.mkIf isInstall "nixsystem";
    inherit stateVersion;

    activationScripts = {
      diff = {
        supportsDryActivation = true;
        text = ''
          BLUE=$(${pkgs.ncurses}/bin/tput setaf 4)
          CLEAR=$(${pkgs.ncurses}/bin/tput sgr0)

          if [[ -e /run/current-system ]]; then
            echo "$BLUE   $CLEAR System Diff Report $BLUE   $CLEAR"
            echo "#"
            ${pkgs.nvd}/bin/nvd --color=always --nix-bin-dir=${config.nix.package}/bin diff $(${pkgs.coreutils}/bin/readlink "/run/current-system") "$systemConfig" | tee /var/log/nix/nix-changelog
            echo "#"
            echo "$BLUE                $CLEAR"
          fi
        '';
      };

    };

    switch = {
      # enable = true; # false; # Perl
      enableNg = true; # Rust-based re-implementation of the original Perl switch-to-configuration
    };
  };
}
