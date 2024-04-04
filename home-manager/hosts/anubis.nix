{ pkgs, config, lib, username, ... }:
with lib.hm.gvariant;
let
  nixGL = import ../../lib/nixGL.nix { inherit config pkgs; };
  # mpv-custom = import ../_mixins/apps/video/mpv.nix;
  vivaldi-custom = pkgs.vivaldi.override { proprietaryCodecs = true; enableWidevine = true; qt = qt6; };

in
{
  imports = [
    # ../_mixins/apps/music/rhythmbox.nix
    # ../_mixins/apps/text-editor/vscode.nix
    # ../_mixins/apps/text-editor/vscodium.nix
    # ../_mixins/apps/terminal/alacritty.nix
    ../_mixins/console/bash.nix
    # ../_mixins/apps/browser/firefox/librewolf.nix
    ../_mixins/apps/video/mpv/mpv-config.nix
    ../_mixins/apps/text-editor/vscode/vscode-config.nix
    ../_mixins/non-nixos
    # ../_mixins/apps/tools/zathura.nix
    # ../_mixins/desktop/bspwm/themes/default
    # ../_mixins/apps/browser/opera.nix
  ];
  config = {
    nix.settings = {
      cores = 2;
      extra-substituters = [ "https://anubis.cachix.org" ];
      extra-trusted-public-keys = [ "anubis.cachix.org-1:p6q0lqdZcE9UrkmFonRSlRPAPADFnZB1atSgp6tbF3U=" ];
    };

    services.nonNixOs.enable = true;

    home = {
      packages = with pkgs; [
        docker-client
        (nixGL vivaldi-custom)
      ];
      file = {
        "bin/create-docker" = {
          enable = true;
          executable = true;
          text = ''
            #!/usr/bin/env bash
            ${pkgs.lima}/bin/limactl list | grep default | grep -q Running || ${pkgs.lima}/bin/limactl start --name=default template://docker # Start/create default lima instance if not running/created
            ${pkgs.docker-client}/bin/docker context create lima-default --docker "host=unix:///Users/${username}/.lima/default/sock/docker.sock"
            ${pkgs.docker-client}/bin/docker context use lima-default
          '';
        };
        # "bin/home-switch" = {
        #   enable = true;
        #   executable = true;
        #   text = ''
        #     #!/usr/bin/env bash
        #     # git clone --depth=1 -b cleanup https://github.com/JucaRei/nixfiles ~/opt/nixos-configs &>/dev/null || true
        #     git clone --depth=1 -b cleanup https://github.com/JucaRei/nixfiles ~/.dotfiles/nixfiles &>/dev/null || true
        #     # git -C ~/opt/nixos-configs pull origin master --rebase
        #     ## OS-specific support (mostly, Ubuntu vs anything else)
        #     ## Anything else will use nixpkgs-unstable
        #     EXTRA_ARGS=""
        #     if grep -iq Ubuntu /etc/os-release
        #     then
        #       version="$(grep VERSION_ID /etc/os-release | cut -d'=' -f2 | tr -d '"')"
        #       ## Support for Ubuntu 22.04
        #       if [[ "$version" == "22.04" ]]
        #       then
        #         EXTRA_ARGS="--override-input nixpkgs-lts github:nixos/nixpkgs/nixos-22.05"
        #       fi
        #       ## TODO: Support Ubuntu 24.04 when released
        #     fi
        #     nix --extra-experimental-features 'nix-command flakes' run "$HOME/opt/nixos-configs#homeConfigurations.heywoodlh.activationPackage" --impure $EXTRA_ARGS
        #   '';
        # };
      };
    };
  };
}
