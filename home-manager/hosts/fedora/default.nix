{ config, ... }: {
  config = {
    system = {
      # services = {
      #   git = {
      #     enable = true;
      #     user = "Reinaldo";
      #     email = "reinaldo800@gmail.com";
      #   };
      # };
      programs = {
        console = {
          bat.enable = true;
          eza.enable = true;
        };
      };
    };
  };
}
