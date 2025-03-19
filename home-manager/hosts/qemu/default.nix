{ config, ... }: {
  imports = [
    ../../../modules/home-manager/programs/terminal
  ];
  config = {
    features.nonNixOs = {
      enable = true;
    };

    programs = {
      terminal = {
        shells = {
          # bash.enable = true;
          # fish.enable = true;
          zsh.enable = true;
        };
        console = {
          starship.enable = true;
        };
      };
    };
  };
}
