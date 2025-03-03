{ ... }: {
  programs = {
    home-manager = {
      enable = true;
    };
    nix-index = {
      enable = true;
    };
  };

  system = {
    user = {
      # Nicely reload system units when changing configs
      startServices = "sd-switch";
    };
  };
}
