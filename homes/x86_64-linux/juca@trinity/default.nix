{ pkgs, ... }: {
  excalibur = {
    roles = {
      common.enable = true;
    };

    user = {
      enable = true;
      name = "juca";
    };
  };

  home.packages = with pkgs; [
    fluxcd
  ];

  home.stateVersion = "23.11";
}
