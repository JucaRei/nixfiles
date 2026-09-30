{ ... }: {
  config = {
    system = {
      programs = {
        browsers = {
          default = "firefox";
          firefox = {
            enable = true;
          };
        };
        terminal = {
          enable = true;
          name = "alacritty";
        };
        console = {
          eza.enable = true;
          bat.enable = true;
        };
        shells = {
          enable = true;
        };
      };
      desktop = {
        modifierKey = "Super";
      };
      services = {
        podman = {
          enable = true;
          autoPrune.enable = true;
        };
      };
    };
  };
}
