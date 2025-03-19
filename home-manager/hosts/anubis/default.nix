{ config, pkgs, inputs, ... }: {
  imports = [
    # ../../_mixins/services/podman
    ../../../modules/home-manager/programs/terminal
  ];
  config = {
    features.nonNixOs = {
      enable = true;
    };
    # console = {
    #   yt-dlp-custom = {
    #     enable = true;
    #   };
    #   starship = {
    #     enable = true;
    #   };
    # };

    programs.terminal = {
      shells = {
        bash.enable = true;
        fish.enable = true;
      };
      console = {
        starship.enable = true;
      };
    };

    home = {
      packages = with pkgs; [
        # fish
      ];
    };

    # nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };
}
